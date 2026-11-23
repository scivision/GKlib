#include <GKlib.h>

int main(void)
{
  char *argv[] = {"test", "-a", "value", "-z", "remaining", NULL};

  gk_optind = 0;
  gk_opterr = 0;
  if (gk_getopt(5, argv, "a:") != 'a' ||
      gk_optarg == NULL || strcmp(gk_optarg, "value") != 0 || gk_optind != 3)
    return 1;
  if (gk_getopt(5, argv, "a:") != '?' || gk_optopt != 'z' || gk_opterr != 0)
    return 1;
  if (gk_getopt(5, argv, "a:") != -1 || gk_optind != 4)
    return 1;

  return 0;
}
