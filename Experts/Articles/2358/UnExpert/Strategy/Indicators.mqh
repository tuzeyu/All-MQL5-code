//+------------------------------------------------------------------+
//|                                                   Indicators.mqh |
//|                                 Copyright 2017, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#include "Message.mqh"
#include "Logs.mqh"
//+------------------------------------------------------------------+
//| Indicator base class                                             |
//+------------------------------------------------------------------+
class CUnIndicator
{
private:
   MqlParam m_params[];
   int      m_params_count;
   int      m_current_buffer;
   int      m_handle;
   static   CLog*    Log;
   bool     m_invalid_handle;
   void     PushName(string name);
public:
            CUnIndicator(void);
   void     SetBuffer(int index);
   template <typename T>
   bool     SetParameter(T value);
   int      Create(string symbol, ENUM_TIMEFRAMES period, string name);
   int      Create(string symbol, ENUM_TIMEFRAMES period, string name, int app_price);
   int      Create(string symbol, ENUM_TIMEFRAMES period, ENUM_INDICATOR ind_type);
   int      Create(string symbol, ENUM_TIMEFRAMES period, ENUM_INDICATOR ind_type, int app_price);
   void     InitByHandle(int handle);
   void     IndicatorRelease(void);
   double   operator[](int index);
   double   operator[](datetime time);
   int      GetHandle(void);
};
CLog        *CUnIndicator::Log;
//+------------------------------------------------------------------+
//| Initialization without specifying the name                       |
//+------------------------------------------------------------------+
CUnIndicator::CUnIndicator(void) : m_params_count(0),
                                   m_handle(INVALID_HANDLE),
                                   m_current_buffer(0),
                                   m_invalid_handle(false)
{
   //ArrayResize(m_params, 1);
   //m_params[0].type = TYPE_STRING;
   Log = CLog::GetLog(); 
}

//+------------------------------------------------------------------+
//| Indicator deinitialization                                       |
//+------------------------------------------------------------------+
CUnIndicator::IndicatorRelease(void)
{
   if(m_handle != INVALID_HANDLE)
      IndicatorRelease(m_handle);
   ArrayResize(m_params, 1);
   m_params_count = 1;
   m_current_buffer = 0;
   m_handle = INVALID_HANDLE;
}

template <typename T>
bool CUnIndicator::SetParameter(T value)
{
   
   string type = typename(value);
   MqlParam param;
   if(type == "string")
   {
      param.type = TYPE_STRING;
      param.string_value = (string)value;
   }
   else if(type == "int")
   {
      param.type = TYPE_INT;
      param.integer_value = (long)value;
   }
   else if(type == "double")
   {
      param.type = TYPE_DOUBLE;
      param.double_value = (double)value;
   }
   else if(type == "bool")
   {
      param.type = TYPE_BOOL;
      param.integer_value = (int)value;
   }
   else if(type == "datetime")
   {
      param.type = TYPE_DATETIME;
      param.integer_value = (datetime)value;
   }
   else if(type == "color")
   {
      param.type = TYPE_COLOR;
      param.integer_value = (color)value;
   }
   else if(type == "ulong")
   {
      param.type = TYPE_ULONG;
      param.integer_value = (long)value;
   }
   else if(type == "uint")
   {
      param.type = TYPE_UINT;
      param.integer_value = (uint)value;
   }
   else
   {
      param.type = TYPE_INT;
      param.integer_value = (int)value;
   }
   m_params_count++;
   if(ArraySize(m_params) < m_params_count)
      ArrayResize(m_params, m_params_count);
   m_params[m_params_count-1].double_value = param.double_value;
   m_params[m_params_count-1].integer_value = param.integer_value;
   m_params[m_params_count-1].string_value = param.string_value;
   m_params[m_params_count-1].type = param.type;
   return true;
}
//+------------------------------------------------------------------+
//| Returns the indicator handle                                     |
//+------------------------------------------------------------------+
int CUnIndicator::GetHandle(void)
{
   return m_handle;
}
//+------------------------------------------------------------------+
//| Sets the current indicator buffer                                |
//+------------------------------------------------------------------+
void CUnIndicator::SetBuffer(int index)
{
   m_current_buffer = index;
}
//+------------------------------------------------------------------+
//| Initializes the indicator (creates its handle) Returns the handle|
//| of indicator if successful, otherwise INVALID_HANDLE if the      |
//| indicator creation failed                                        |
//+------------------------------------------------------------------+
int CUnIndicator::Create(string symbol, ENUM_TIMEFRAMES period, string name)
{
   PushName(name);
   m_handle = IndicatorCreate(symbol, period, IND_CUSTOM, m_params_count, m_params);
   if(m_handle == INVALID_HANDLE && m_invalid_handle == false)
   {
      string text = "CUnIndicator '" + m_params[0].string_value + "' was not created. Check its params. Last error:" + (string)GetLastError();
      CMessage* msg = new CMessage(MESSAGE_ERROR, __FUNCTION__, text);
      Log.AddMessage(msg);
      m_invalid_handle = true;
   }
   return m_handle;
}
//+------------------------------------------------------------------+
//| Initializes the indicator (creates its handle) Returns the handle|
//| of indicator if successful, otherwise INVALID_HANDLE if the      |
//| indicator creation failed                                        |
//+------------------------------------------------------------------+
int CUnIndicator::Create(string symbol, ENUM_TIMEFRAMES period, ENUM_INDICATOR ind_type)
{
   if(ind_type == IND_CUSTOM)
   {
      string text = "CUnIndicator '" + m_params[0].string_value + "' was not created. Indicator type can not be IND_CUSTOM";
      CMessage* msg = new CMessage(MESSAGE_ERROR, __FUNCTION__, text);
      Log.AddMessage(msg);
      m_invalid_handle = true;
      return INVALID_HANDLE;
   }
   m_handle = IndicatorCreate(symbol, period, ind_type, m_params_count, m_params);
   if(m_handle == INVALID_HANDLE && m_invalid_handle == false)
   {
      string text = "CUnIndicator '" + m_params[0].string_value + "' was not created. Check its params. Last error:" + (string)GetLastError();
      CMessage* msg = new CMessage(MESSAGE_ERROR, __FUNCTION__, text);
      Log.AddMessage(msg);
      m_invalid_handle = true;
   }
   return m_handle;
}
//+------------------------------------------------------------------+
//| Initializes the indicator (creates its handle) Returns the handle|
//| of indicator if successful, otherwise INVALID_HANDLE if the      |
//| indicator creation failed                                        |
//+------------------------------------------------------------------+
int CUnIndicator::Create(string symbol,ENUM_TIMEFRAMES period,ENUM_INDICATOR ind_type,int app_price)
{
   SetParameter(app_price);
   return Create(symbol, period, ind_type);
}
//+------------------------------------------------------------------+
//| Places the indicator name at the zero index of m_params[] array  |
//+------------------------------------------------------------------+
void CUnIndicator::PushName(string name)
{
   int old_size = ArraySize(m_params);
   int size = ArrayResize(m_params, ArraySize(m_params) + 1);
   for(int i = 0; i < old_size; i++)
      m_params[i+1] = m_params[i];
   m_params[0].type = TYPE_STRING;
   m_params[0].string_value = name;
}
//+------------------------------------------------------------------+
//| Initializes the indicator (creates its handle) Returns the handle|
//| of indicator if successful, otherwise INVALID_HANDLE if the      |
//| indicator creation failed                                        |
//+------------------------------------------------------------------+
int CUnIndicator::Create(string symbol, ENUM_TIMEFRAMES period, string name, int app_price)
{
   SetParameter(app_price);
   return Create(symbol, period, name);
}
//+------------------------------------------------------------------+
//| Initializes an indicator class based on an existing              |
//| indicator handle                                                 |
//+------------------------------------------------------------------+
void CUnIndicator::InitByHandle(int handle)
{
   this.IndicatorRelease();
   m_handle = handle;
}
//+------------------------------------------------------------------+
//| Returns the indicator value based on 'index'                     |
//+------------------------------------------------------------------+
double CUnIndicator::operator[](int index)
{
   double values[];
   if(m_handle == INVALID_HANDLE)
      return EMPTY_VALUE;
   if(CopyBuffer(m_handle, m_current_buffer, index, 1, values) == 0)
   {
      string text = "Failed copy buffer of indicator. Last error: " + (string)GetLastError();
      CMessage* msg = new CMessage(MESSAGE_ERROR, __FUNCTION__, text);
      Log.AddMessage(msg);
      return EMPTY_VALUE;
   }
   return values[0];
}
//+------------------------------------------------------------------+
//| Returns the indicator value based on 'time'                      |
//+------------------------------------------------------------------+
double CUnIndicator::operator[](datetime time)
{
   double values[];
   if(m_handle == INVALID_HANDLE)
      return EMPTY_VALUE;
   
   if(CopyBuffer(m_handle, m_current_buffer, time, 1, values) == 0)
   {
      string text = "Failed copy buffer of indicator. Last error: " + (string)GetLastError();
      CMessage* msg = new CMessage(MESSAGE_ERROR, __FUNCTION__, text);
      Log.AddMessage(msg);
      return EMPTY_VALUE;
   }
   return values[0];
}