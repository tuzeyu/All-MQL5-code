//+------------------------------------------------------------------+
//|                                               TrailingMoving.mqh |
//|                                 Copyright 2016, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#include "Trailing.mqh"
#include "..\Indicators\MovingAverage.mqh"

//+------------------------------------------------------------------+
//| Trailing stop based on MovingAverage.  Sets a stop loss of       |
//| a position equal to the MA level                                 |
//+------------------------------------------------------------------+
class CTrailingMoving : public CTrailing
{
public:
   virtual bool       Modify(void);
   CIndMovingAverage* Moving;
   virtual CTrailing* Copy(void);
};
//+------------------------------------------------------------------+
//| Sets the stop-loss of a position equal to the MA level           |
//+------------------------------------------------------------------+
bool CTrailingMoving::Modify(void)
{
   if(CheckPointer(Moving) == POINTER_INVALID)
      return false;
   double value = Moving.OutValue(1);
   if(m_position.Direction() == POSITION_TYPE_BUY &&
      value > m_position.CurrentPrice())
      m_position.CloseAtMarket();
   else if(m_position.Direction() == POSITION_TYPE_SELL &&
      value < m_position.CurrentPrice())
      m_position.CloseAtMarket();
   else if(m_position.StopLossValue() != value)
      return m_position.StopLossValue(value);
   return false;
}
//+------------------------------------------------------------------+
//| Returns an exact copy of the CTrailingMoving instance            |
//+------------------------------------------------------------------+
CTrailing* CTrailingMoving::Copy(void)
{
   CTrailingMoving* mov = new CTrailingMoving();
   mov.Moving = Moving;
   return mov;
}