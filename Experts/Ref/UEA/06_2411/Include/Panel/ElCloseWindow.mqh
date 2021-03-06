//+------------------------------------------------------------------+
//|                                                ElCloseWindow.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#include "ElChart.mqh"
//+------------------------------------------------------------------+
//| The x icon closing the window                                    |
//+------------------------------------------------------------------+
class CElCloseWin : public CElChart
  {
public:
                     CElCloseWin(void);
   virtual void      OnClick(CEventChartObjClick *event);
  };
//+------------------------------------------------------------------+
//| The x icon closing the window                                    |
//+------------------------------------------------------------------+
CElCloseWin::CElCloseWin(void) : CElChart(OBJ_EDIT)
  {
   Width(36);
   Height(18);
   BackgroundColor(C'214,84,0');
//BorderColor(clrGainsboro);
   TextColor(clrWhiteSmoke);
   TextFont("Webdings");
   TextSize(12);
   Text(""+CharToString(0x72));
   Align(ALIGN_CENTER);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CElCloseWin::OnClick(CEventChartObjClick *event)
  {
   if(event.ObjectName()==Name())
      ExpertRemove();
  }
//+------------------------------------------------------------------+
