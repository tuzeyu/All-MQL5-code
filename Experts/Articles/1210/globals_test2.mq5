//+------------------------------------------------------------------+
//|                                                Globals_test2.mq5 |
//|                                           Copyright 2014, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, denkir"
#property link      "https://login.mql5.com/ru/users/denkir"
#property version   "1.00"
#property script_show_inputs
//---
#include "CGlobalVar.mqh"

input uint InpCnt=10000; // Number of variables
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   int  deleted_num=GlobalVariablesDeleteAll();
//--- store the initial value
   uint start=GetTickCount();
//---
   for(uint idx=0;idx<InpCnt;idx++)
     {
      CGlobalVar gVar;
      //--- Create a temporary global var
      if(!gVar.Create("Test_var"+IntegerToString(idx+1),idx+0.15))
         Alert("Error creating a global variable!");
     }
//--- get the spent time in milliseconds
   uint time=GetTickCount()-start;
//--- display the error message in the Experts journal
   PrintFormat("Creation of %d global variables took %d ms",InpCnt,time);
  }
//+------------------------------------------------------------------+
