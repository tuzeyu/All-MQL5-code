//+------------------------------------------------------------------+
//|                                                Globals_test3.mq5 |
//|                                           Copyright 2014, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, denkir"
#property link      "https://login.mql5.com/ru/users/denkir"
#property version   "1.00"
#property script_show_inputs

//---
#include "CGlobalVarList.mqh"
//---
input ENUM_GVARS_TYPE InpGvarType=GVARS_TYPE_FULL; // Set gvar type
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   CGlobalVarList gvarList;
//--- delete gvars
   gvarList.SetGvarType(InpGvarType);
//--- load current gvars  
   gvarList.LoadCurrentGlobals();
   Print("Print the list before deletion.");
   gvarList.Print(10);
//--- delete gvars
   if(gvarList.KillCurrentGlobals())
     {
      Print("Print the list after deletion.");
      gvarList.Print(10);
     }
  }
//+------------------------------------------------------------------+
