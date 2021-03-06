//+------------------------------------------------------------------+
//|                                                   TimeSeries.mqh |
//|                                 Copyright 2017, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#include <Arrays\ArrayObj.mqh>

#include "TimeValue.mqh"
//+------------------------------------------------------------------+
//| Universal timeseries: stores the values of TimeValue and         |
//| provides quick access to them                                    |
//+------------------------------------------------------------------+
class CTimeSeries
{
private:
   CArrayObj   m_series;
   bool        m_reverse;
   datetime    FromFinamData(string data);
public:
   bool        Add(datetime time, double value);
   bool        Add(datetime time, double& values[]);
   void        AddOrChange(datetime time, double value, int buff_index=0);
   void        Clear();
   int         Total(void){return m_series.Total();}
   double      operator[](int index);
   double      operator[](datetime time);
   bool        GetReverse(void);
   void        SetReverse(bool reverse);
   CTimeValue* GetTimeValue(datetime time);
   CTimeValue* GetTimeValue(int index);
   void        OrderBy(ENUM_COMP_TYPE comp_type);
   int         SearchLessOrEqual(datetime time);
   bool        SaveToCsv(datetime begin_time, datetime end_time, string path, int common=FILE_COMMON, int time_format=TIME_DATE|TIME_MINUTES, int digits = 4, uchar del = ';');
               CTimeSeries(void);
   bool        LoadFromCsv(string path_csv, uchar del=',', int line_begin=0, int common = FILE_COMMON);
   int         LoadFromArray(uchar& array[], uchar del=',', int line_begin=0);
   bool        ExitsDataByTime(datetime time);
   void        ToDoubleArray(double& array[]);
   void        ToDoubleArray(int column, double& array[]);
};
//+------------------------------------------------------------------+
//| Default initialization                                           |
//+------------------------------------------------------------------+
CTimeSeries::CTimeSeries() : m_reverse(false)
{
   OrderBy(COMP_BY_TIME);
}
//+------------------------------------------------------------------+
//| Sorting series                                                   |
//+------------------------------------------------------------------+
void CTimeSeries::OrderBy(ENUM_COMP_TYPE comp_type)
{
   m_series.Sort(comp_type);
}
//+------------------------------------------------------------------+
//| Adds a new value to the collection. If the data for the specified|
//| date already exist, returns false, and the data are not added    |
//+------------------------------------------------------------------+
bool CTimeSeries::Add(datetime time,double value)
{
   if(ExitsDataByTime(time))
      return false;
   CTimeValue* tv = new CTimeValue(time, value);
   return m_series.InsertSort(tv);
}
//+------------------------------------------------------------------+
//| Returns the first column as an array of type double              |
//+------------------------------------------------------------------+
void CTimeSeries::ToDoubleArray(double &array[])
{
   ToDoubleArray(0, array);
}
//+------------------------------------------------------------------+
//| Returns column with number 'column' as an array of type double   |
//+------------------------------------------------------------------+
void CTimeSeries::ToDoubleArray(int column,double &array[])
{
   int total = m_series.Total();
   ArrayResize(array, total);
   for(int i = 0; i < total; i++)
   {
      CTimeValue* tv = m_series.At(i);
      array[i] = tv.Value(column);
   }
}
//+------------------------------------------------------------------+
//| Returns true if the data for the specified date exist            |
//| returns false otherwise                                          |
//+------------------------------------------------------------------+
bool CTimeSeries::ExitsDataByTime(datetime time)
{
   if(m_series.Total() == 0)
      return false;
   CTimeValue* t = m_series.At(m_series.Total()-1);
   if(t.Time() < time)
      return false;
   if(t.Time() == time)
      return true;
   CTimeValue* tv_s = new CTimeValue(time, 0.0);
   int index = m_series.Search(tv_s);
   delete tv_s;
   return (index != -1);
}
//+------------------------------------------------------------------+
//| Adds a new value to the collection, if a value with such time    |
//| is not present. If an element with this time at the specified    |
//| index exists, modifies its values                                |
//+------------------------------------------------------------------+
void CTimeSeries::AddOrChange(datetime time,double value, int buff_index=0)
{
   if(m_series.SortMode() != COMP_BY_TIME)
      m_series.Sort(COMP_BY_TIME);
   int index = -1;
   if(m_series.Total() > 0)
   {
      CTimeValue* t = m_series.At(m_series.Total()-1);
      if(t.Time() > time)
      {
         CTimeValue* tv_s = new CTimeValue(time, value);
         index = m_series.Search(tv_s);
         delete tv_s;
      }
   }
   CTimeValue* tv = NULL;
   if(index == -1)
   {
      tv = new CTimeValue(time, value);
      m_series.InsertSort(tv);
   }
   else
   {
      tv = m_series.At(index);
      tv.Value(buff_index, value);
   }
}
//+------------------------------------------------------------------+
//| Saves content to a CSV file                                      |
//+------------------------------------------------------------------+
bool CTimeSeries::SaveToCsv(datetime begin_time, datetime end_time, string path, int common=FILE_COMMON, int time_format=TIME_DATE|TIME_MINUTES, int digits = 4, uchar del = ';')
{
   string lines[];
   int total = ArrayResize(lines, m_series.Total());
   string s = "";
   int count = 0;
   for(int i = 0; i < total; i++)
   {
      CTimeValue* tv = m_series.At(i);
      if(tv.Time() < begin_time)
         continue;
      if(tv.Time() > end_time)
         break;
      lines[count] = tv.ToString(time_format, digits, del)+"\r\n";
      count++;
      s = lines[i];
   }
   total = ArrayResize(lines, count);
   int h = FileOpen(path, FILE_WRITE|FILE_TXT|common, del, CP_ACP);
   if(h == INVALID_HANDLE)
      return false;
   for(int i = 0; i < total; i++)
      FileWriteString(h, lines[i]);
   FileClose(h);
   return true;
}
//+------------------------------------------------------------------+
//| Removes all items from the collection                            |
//+------------------------------------------------------------------+
void CTimeSeries::Clear(void)
{
   m_series.Clear();
}
//+------------------------------------------------------------------+
//| Adds a list of new values to the collection                      |
//+------------------------------------------------------------------+
bool CTimeSeries::Add(datetime time,double& values[])
{
   if(time == D'2017.06.12')
      int dbg = 4;
   if(ExitsDataByTime(time))
      return false;
   CTimeValue* tv = new CTimeValue(time, values);
   return m_series.InsertSort(tv);
}
//+------------------------------------------------------------------+
//| Sets direct or reverse indexation in a collection                |
//+------------------------------------------------------------------+
void CTimeSeries::SetReverse(bool reverse)
{
   m_reverse = reverse;
}
//+------------------------------------------------------------------+
//| Returns true if reverse indexation is used, returns false        |
//| if otherwise.                                                    |
//+------------------------------------------------------------------+
bool CTimeSeries::GetReverse(void)
{
   return m_reverse;
}
//+------------------------------------------------------------------+
//| Get the index value                                              |
//+------------------------------------------------------------------+
double CTimeSeries::operator[](int index)
{
   CTimeValue* tv = NULL;
   if(!m_reverse)
      tv = m_series.At(index);
   else
   {
      int ri = m_series.Total() - index - 1;
      tv = m_series.At(ri);
   }
   return tv.Value();
}
//+------------------------------------------------------------------+
//| Returns the closest value with a smaller or the same time        |
//+------------------------------------------------------------------+
double CTimeSeries::operator[](datetime time)
{
   int index = SearchLessOrEqual(time);
   if(index == -1)
      return EMPTY_VALUE;
   CTimeValue* tv = m_series.At(index);
   return tv.Value();
}
//+------------------------------------------------------------------+
//| Returns the closest value with a smaller or the same time        |
//| TimeValue                                                        |
//+------------------------------------------------------------------+
CTimeValue* CTimeSeries::GetTimeValue(datetime time)
{
   CTimeValue* tv = NULL;
   int index = SearchLessOrEqual(time);
   if(index == -1)
      return tv;
   tv = m_series.At(index);
   return tv;
}
//+------------------------------------------------------------------+
//| Returns the TimeValue corresponding to the index                 |
//+------------------------------------------------------------------+
CTimeValue* CTimeSeries::GetTimeValue(int index)
{
   return m_series.At(index);
}
//+------------------------------------------------------------------+
//| Returns index of element with time equal to specified.           |
//| If no element with this time exist, returns an element with time |
//| less than specified but greater than other elements with smaller |
//| time                                                             |
//+------------------------------------------------------------------+
int CTimeSeries::SearchLessOrEqual(datetime time)
{
   CTimeValue* tv_s = new CTimeValue(time, EMPTY_VALUE);
   if(m_series.SortMode() != COMP_BY_TIME)
      m_series.Sort(COMP_BY_TIME);
   int index = m_series.SearchLessOrEqual(tv_s);
   delete tv_s;
   return index;
}
//+------------------------------------------------------------------+
//| Loads a CSV file from the drive to a timeseries                  |
//+------------------------------------------------------------------+
bool CTimeSeries::LoadFromCsv(string path_csv, uchar del=',', int line_begin=0, int common = FILE_COMMON)
{
   int h = FileOpen(path_csv, FILE_READ|FILE_BIN|common);
   if(h == INVALID_HANDLE)
   {
      printf("Failed open file " + path_csv + " Last error: " + (string)GetLastError());
      return false;
   }
   uchar array[];
   FileReadArray(h, array, 0, WHOLE_ARRAY);
   FileClose(h);
   return (LoadFromArray(array, del, line_begin)>0);
}
//+------------------------------------------------------------------+
//| Loads a CSV file passed as a byte array to a timeseries.         |
//|                                                                  |
//| Returns the number of lines added                                |
//+------------------------------------------------------------------+
int CTimeSeries::LoadFromArray(uchar &array[], uchar del=',',int line_begin=0)
{
   string csv = CharArrayToString(array, 0, WHOLE_ARRAY, CP_ACP);
   string lines[];
   StringSplit(csv, '\n', lines);
   int total = ArraySize(lines);
   int count = 0;
   for(int i = line_begin; i < total; i++)
   {
      string col[];
      double values[];
      string l = lines[i];
      if(StringSplit(lines[i], del, col)<=1)
         continue;
      int col_size = ArraySize(col)-1;
      ArrayResize(values, col_size);
      datetime time = FromFinamData(col[0]);
      for(int c = 1; c <= col_size; c++)
         values[c-1] = StringToDouble(col[c]);
      if(Add(time, values))
         count++;
   }
   return count;
}
//+------------------------------------------------------------------+
//| Parses the broker date                                           |
//+------------------------------------------------------------------+
datetime CTimeSeries::FromFinamData(string data)
{
   int l = StringLen(data);
   uchar ch = (uchar)StringGetCharacter(data, 0);
   int year = (int)StringSubstr(data, 0, 4);
   int month = (int)StringSubstr(data, 4, 2);
   int day = (int)StringSubstr(data, 6, 2);
   MqlDateTime time_str={0};
   time_str.day = day;
   time_str.year = year;
   time_str.mon = month;
   return StructToTime(time_str);
}