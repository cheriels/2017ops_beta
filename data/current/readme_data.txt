

withdrawal_daily_mgd.csv:
CS, 2017-7-18: This is the set of daily withdrawal time series for all six CO-OP supplier intake locations. (We need to get this data from the suppliers.) It is currently just estimated withdrawals, from 2017-1-1 to 2018-1-1, identical to the time series in the file, ..\historical\10-day_rolling_ave_1999-2013_withdrawal.csv. The time series in that file in turn are from 10-day centered rolling averages of 1999-2013 production data (and with production converted to withdrawals by multiplying by 1.03). These were created in H:\ICPRB2\USERS2\COOP\RealtimeP5\Model\wdm updates\create_div_ts.xlsx.
Note I’m assuming that our data from the suppliers is production data – need to verify.

flow_daily_mgd.csv:
CS, 2017-7-18: Currently this is daily flow data at selected USGS real-time stream gage sites in the Potomac basin, from 2017-1-1 to present (assuming it has been updated through the current day). Non-numeric values (e.g. “ice”, “Eqp”, or “#N/A”) or “0”’s which appeared to indicate missing values, were crudely replaced with plausible values in H:\ICPRB2\USERS2\COOP\Drought Exercise-Operations\2017\Data_Daily.xlsx.

flow_hourly_mgd.csv:
CS, 2017-7-18: Currently this is hourly flow data at selected USGS real-time stream gage sites in the Potomac basin, from 2017-1-1 to present (assuming it has been updated through the current day).
