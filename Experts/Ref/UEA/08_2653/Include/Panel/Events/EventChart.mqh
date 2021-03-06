//+------------------------------------------------------------------+
//|                                                   EventChart.mqh |
//+------------------------------------------------------------------+
#include "Event.mqh"
///
///
///
class CEventChart : public CEvent
  {
private:
   int               m_id;
   long              m_lparam;
   double            m_dparam;
   string            m_sparam;
private:
                     CEventChart(ENUM_EVENT_TYPE event_type,const int id,const long &lparam,const double &dparam,const string &sparam);
public:
   int               ID(void);
   long              LParam(void);
   double            DParam(void);
   string            SParam(void);
   static CEventChart *CreateChartEvent(int id,const long &lparam,const double &dparam,const string &sparam);
  };
///
/// Sets a call
///
CEventChart::CEventChart(ENUM_EVENT_TYPE event_type,
                         const int id,
                         const long &lparam,
                         const double &dparam,
                         const string &sparam) : CEvent(event_type)
  {
   m_id=id;
   m_lparam = lparam;
   m_dparam = dparam;
   m_sparam = sparam;
  }
///
/// Returns the identifier of the graphic event
///
int CEventChart::ID(void)
  {
   return m_id;
  }
///
/// Returns a long-type parameter if the graphic event
///
long CEventChart::LParam(void)
  {
   return m_lparam;
  }
///
/// Returns a double-type parameter if the graphic event
///
double CEventChart::DParam(void)
  {
   return m_dparam;
  }
///
/// Returns a string-type parameter if the graphic event
///
string CEventChart::SParam(void)
  {
   return m_sparam;
  }
///
/// Creates the Graphic Event object
///
CEventChart *CEventChart::CreateChartEvent(int id,const long &lparam,const double &dparam,const string &sparam)
  {
   return new CEventChart(EVENT_CHART_CUSTOM, id, lparam, dparam, sparam);
  }
//+------------------------------------------------------------------+
