int i, j;
int main() {

  int k, ll, m, n, o, p;

  i = 1;
  println(i);
  j = 5 + 8;
  println(j);
  k = i + 2 * j;
  println(k);

  m = k % 9;
  println(m);

  p = 1;

  p++;
  println(p);

  k = -p;
  println(k);

  int a[10];

  a[1 + 2 - 3] = 3;
  println(a[1 + 2 - 3]);

  int b[4];

  b[0] = 1;

  a[3] = b[0];
  println(a[3]);
  println(b[0]);

  return 0;
}