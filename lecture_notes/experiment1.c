#include <stdio.h>

int main() {
  int x = 5;
  int y = 8;
  int *p;
  int *q;
  p = &x;
  q = &y;
  printf("x: %d, p: %d, *p: %d, y: %d, q: %d, *q: %d\n", x, p, *p, y, q, *q);
  p--;
  printf("x: %d, p: %d, *p: %d, y: %d, q: %d, *q: %d\n", x, p, *p, y, q, *q);
  *p = 9;
  printf("x: %d, p: %d, *p: %d, y: %d, q: %d, *q: %d\n", x, p, *p, y, q, *q);

  int a[4] = {10,11,12,13};
  int b[4] = {14,15,16,17};
  printf("a: %d, &a[0]: %d, &a[1]: %d\n", a, &a[0], &a[1]);
  printf("2[a]: %d\n", 2[a]);

  printf("b: %d, &b[0]: %d, &b[1]: %d\n", b, &b[0], &b[1]);
  b[4] = 88;
  b[5] = 99;
  printf("a[0]: %d, a[1]: %d\n", a[0], a[1]);
  printf("&a: %d, &b: %d\n", &a, &b);
  
  return 0;
}
