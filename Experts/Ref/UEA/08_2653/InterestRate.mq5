//+------------------------------------------------------------------+
//|                                                 InterestRate.mq5 |
//|                                 Copyright 2017, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include "InterestRate.mqh"
#include <Strategy\Strategy.mqh>
#include <Strategy\StrategiesList.mqh>

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   CIntRate* rate = new CIntRate();
   rate.ExpertMagic(1293);
   rate.ExpertName("Interest Rate Panel");
   rate.Timeframe(PERIOD_M1);
   rate.ExpertSymbol(Symbol());
   Manager.AddStrategy(rate);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   Manager.OnTick();
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int    id,
                  const long   &lparam,
                  const double &dparam,
                  const string &sparam)
{
   Manager.OnChartEvent(id, lparam, dparam, sparam);
   ChartRedraw(0);
}
//+------------------------------------------------------------------+
