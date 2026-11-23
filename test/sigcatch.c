#include <GKlib.h>

static int nested_trap(void)
{
  if (!gk_sigtrap())
    return 1;

  switch (gk_sigcatch()) {
    case 0:
      gk_sigthrow(SIGMEM);
      return 1;
    case SIGMEM:
      return !gk_siguntrap();
    default:
      return 1;
  }
}

int main(void)
{
  if (!gk_sigtrap())
    return 1;

  switch (gk_sigcatch()) {
    case 0:
      if (nested_trap())
        return 1;
      gk_sigthrow(SIGERR);
      return 1;
    case SIGERR:
      return !gk_siguntrap();
    default:
      return 1;
  }
}
