/* Mandelbrot strip renderer — one job-array task renders rows [row0, row1).
 * Usage: ./mandel W H max_iter row0 row1 outfile
 * Writes raw RGB bytes (no header); strips concatenate into a P6 PPM.
 */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(int argc, char **argv) {
    if (argc != 7) { fprintf(stderr, "usage: %s W H max_iter row0 row1 outfile\n", argv[0]); return 1; }
    int W = atoi(argv[1]), H = atoi(argv[2]), max_iter = atoi(argv[3]);
    int row0 = atoi(argv[4]), row1 = atoi(argv[5]);
    FILE *f = fopen(argv[6], "wb");
    if (!f) { perror("fopen"); return 1; }

    const double x_min = -2.55, x_max = 0.95, y_min = -1.25, y_max = 1.25;
    unsigned char *buf = malloc((size_t)W * 3);

    for (int py = row0; py < row1; py++) {
        double cy = y_min + (y_max - y_min) * py / (H - 1);
        for (int px = 0; px < W; px++) {
            double cx = x_min + (x_max - x_min) * px / (W - 1);
            double x = 0, y = 0, x2 = 0, y2 = 0;
            int n = 0;
            while (x2 + y2 <= 4.0 && n < max_iter) {
                y = 2 * x * y + cy;
                x = x2 - y2 + cx;
                x2 = x * x; y2 = y * y;
                n++;
            }
            unsigned char r = 0, g = 0, b = 0;
            if (n < max_iter) {                       /* exterior: smooth cosine palette */
                double nu = n + 1.0 - log2(log2(sqrt(x2 + y2)));
                double t = 0.05 * nu;
                r = (unsigned char)(255 * (0.5 + 0.5 * cos(3.0 + t * 3.0)));
                g = (unsigned char)(255 * (0.5 + 0.5 * cos(3.6 + t * 3.0)));
                b = (unsigned char)(255 * (0.5 + 0.5 * cos(4.2 + t * 3.0)));
            }
            buf[3 * px] = r; buf[3 * px + 1] = g; buf[3 * px + 2] = b;
        }
        fwrite(buf, 3, W, f);
    }
    free(buf); fclose(f);
    return 0;
}
