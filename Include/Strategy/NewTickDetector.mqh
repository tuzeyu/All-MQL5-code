//+------------------------------------------------------------------+
//|                                              NewTickDetector.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Object.mqh>
//+------------------------------------------------------------------+
//| New tick detector                                                |
//+------------------------------------------------------------------+
class CTickDetector : public CObject
  {
private:
   string            m_symbol;         // The symbol to track the arrival of a new tick for
   MqlTick           m_last_tick;      // Last remembered tick.
public:
                     CTickDetector(void);
                     CTickDetector(string symbol);
   string            Symbol(void);
   void              Symbol(string symbol);
   bool              IsNewTick(void);
  };
//+------------------------------------------------------------------+
//| By default the constructor sets the current timeframe            |
//| and symbol.                                                      |
//+------------------------------------------------------------------+
CTickDetector::CTickDetector(void)
  {
   m_symbol=_Symbol;
  }
//+------------------------------------------------------------------+
//| Creates an object with a predefined symbol and timeframe.        |
//+------------------------------------------------------------------+
CTickDetector::CTickDetector(string symbol)
  {
   m_symbol=symbol;
  }
//+------------------------------------------------------------------+
//| Sets the name of the symbol on which you want to track           |
//| the emergence of a new bar.                                      |
//+------------------------------------------------------------------+
void CTickDetector::Symbol(string symbol)
  {
   m_symbol=symbol;
  }
//+------------------------------------------------------------------+
//| Returns the name of the symbol on which you track the            |
//| emergence of a new bar.                                          |
//+------------------------------------------------------------------+
string CTickDetector::Symbol(void)
  {
   return m_symbol;
  }
//+------------------------------------------------------------------+
//| Returns true if for the given symbol and timeframe there is      |
//| a new tick.                                                      |
//+------------------------------------------------------------------+
bool CTickDetector::IsNewTick(void)
  {
   MqlTick tick;
   SymbolInfoTick(m_symbol,tick);
   if(tick.last!=m_last_tick.last || 
      tick.time!=m_last_tick.time)
     {
      m_last_tick=tick;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
