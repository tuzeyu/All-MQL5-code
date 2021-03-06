//+------------------------------------------------------------------+
//|                                                       Target.mqh |
//|           Copyright 2016, Vasiliy Sokolov, St-Petersburg, Russia |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "https://www.mql5.com/en/users/c-4"
#include <Object.mqh>
//+------------------------------------------------------------------+
//| Target - element of complex position scenario.                   |
//| It indicates what volume for what symbol you need to             |
//| execute during complex position execution.                       |
//+------------------------------------------------------------------+
class CTarget : public CObject
  {
private:
   string            m_symbol;        // The symbol you need to execute a deal for
   double            m_volume;        // Deal volume. If the deal volume is less than zero, you should sell,
                                      // if more than zero, you should buy
public:
                     CTarget(string symbol,double volume);
   string            Symbol();
   double            Volume();
   bool              operator!=(CTarget *target)const;
   bool              operator==(CTarget *target)const;
   CTarget          *Clone(void);
  };
//+------------------------------------------------------------------+
//| By default target is created with the indication of a symbol     |
//| and trading volume.                                              |
//+------------------------------------------------------------------+
CTarget::CTarget(string symbol,double volume)
  {
   m_symbol = symbol;
   m_volume = volume;
  }
//+------------------------------------------------------------------+
//| Returns the target symbol                                        |
//+------------------------------------------------------------------+
string CTarget::Symbol(void)
  {
   return m_symbol;
  }
//+------------------------------------------------------------------+
//| Returns the target volume                                        |
//+------------------------------------------------------------------+
double CTarget::Volume(void)
  {
   return m_volume;
  }
//+------------------------------------------------------------------+
//| For convenience override the "equal" operator                    |
//+------------------------------------------------------------------+
bool CTarget::operator==(CTarget *target)const
  {
   if(target.Symbol() == m_symbol &&
      target.Volume() == m_volume)return true;
   return false;
  }
//+------------------------------------------------------------------+
//| For convenience override operator "not equal".                   |
//+------------------------------------------------------------------+
bool CTarget::operator!=(CTarget *target)const
  {
   return !(target == GetPointer(this));
  }
//+------------------------------------------------------------------+
//| Clones the current target and returns its full copy.             |
//+------------------------------------------------------------------+
CTarget *CTarget::Clone(void)
  {
   CTarget *target=new CTarget(m_symbol,m_volume);
   return target;
  }
//+------------------------------------------------------------------+
