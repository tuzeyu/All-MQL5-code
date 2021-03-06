//+------------------------------------------------------------------+
//|                                                       Agent.mq5  |
//|           Copyright 2016, Vasiliy Sokolov, St-Petersburg, Russia |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "https://www.mql5.com/en/users/c-4"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
//#include <Strategy\Samples\SignalMACD.mqh>
//#include <Strategy\Samples\SignalWithAdapter.mqh>
#include <Strategy\Samples\Signal_RSI_AC.mqh>
CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() 
{
   //COnSignalMACD* signal = new COnSignalMACD();
   //CAdapterMACD* signal = new CAdapterMACD();
   COnSignal_RSI_AC* signal = new COnSignal_RSI_AC();
   signal.ExpertMagic(2918);
   signal.ExpertName("MQL Signal Samples");
   signal.Timeframe(Period());
   if(!Manager.AddStrategy(signal))
      delete signal;
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
//| OnChartEvent function                                               |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   Manager.OnChartEvent(id, lparam, dparam, sparam);
}