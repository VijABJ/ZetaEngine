unit ZetaTypes;

interface

type
  tINTBOOL      = integer;
  tCONTROL      = integer;
  tCALLBACK     = integer;

const
  IBOOL_TRUE    = 1;
  IBOOL_FALSE   = 0;
  IBOOL: array [boolean] of tINTBOOL = (IBOOL_FALSE, IBOOL_TRUE);
  BOOL: array[IBOOL_FALSE..IBOOL_TRUE] of boolean = (FALSE, TRUE);

  tNULL_CONTROL = 0;



implementation

end.
