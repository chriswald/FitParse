﻿using Dynastream.Fit;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace FitParse
{
	class Database
	{
		private SqlConnection conn;

		public void Connect()
		{
			string host = ConfigurationManager.AppSettings["Hostname"];
			string port = ConfigurationManager.AppSettings["Port"];
			string database = ConfigurationManager.AppSettings["Database"];
			string username = ConfigurationManager.AppSettings["Username"];
			string password = ConfigurationManager.AppSettings["Password"];

			conn = new SqlConnection(
				$"Server=tcp:{host},{port};Database={database};Uid={username};Pwd={password}");

			conn.Open();
		}

		public void Query()
		{
			string query = "SELECT * FROM SPORT";
			using (SqlCommand cmd = new SqlCommand(query, conn))
			{
				DataTable table = new DataTable("Sport");
				SqlDataAdapter dap = new SqlDataAdapter(cmd);

				dap.Fill(table);

				foreach (DataRow row in table.Rows)
				{
					foreach (object item in row.ItemArray)
					{
						Console.Write($"{item.ToString()}\t");
					}
					Console.WriteLine();
				}
			}
		}

		public void UploadRide(List<ActivityMesg> activities, List<SessionMesg> sessions, List<LapMesg> laps, List<RecordMesg> records)
		{
			foreach (ActivityMesg activity in activities)
			{
				int activityId = this.AddActivity(activity);

				// If upload failed skip the rest
				if (activityId == -1) { continue; }

				int activityEnd = Convert.ToInt32(activity.GetFieldValue(ActivityMesg.FieldDefNum.Timestamp));
				int activityDuration = Convert.ToInt32(activity.GetFieldValue(ActivityMesg.FieldDefNum.TotalTimerTime));
				int activityStart = activityEnd - activityDuration;

				UploadSessions(sessions, laps, records, activityId, activityStart, activityEnd);
			}
		}

		private void UploadSessions(List<SessionMesg> sessions, List<LapMesg> laps, List<RecordMesg> records, int activityId, int activityStart, int activityEnd)
		{
			List<SessionMesg> sessionsToRemove = new List<SessionMesg>();

			foreach (SessionMesg session in sessions)
			{
				int sessionStart = Convert.ToInt32(session.GetFieldValue(SessionMesg.FieldDefNum.StartTime));
				if (sessionStart < activityStart || sessionStart > activityEnd) { continue; }

				int sessionId = this.AddSession(session, activityId);
				sessionsToRemove.Add(session);

				if (sessionId == -1) { continue; }

				int sessionDuration = Int32F(session, SessionMesg.FieldDefNum.TotalElapsedTime) ?? 0;
				int sessionEnd = sessionStart + sessionDuration;

				UploadLaps(laps, records, sessionId, sessionStart, sessionEnd);
			}

			// Remove associated sessions
			foreach (SessionMesg session in sessionsToRemove)
			{
				sessions.Remove(session);
			}
		}

		private void UploadLaps(List<LapMesg> laps, List<RecordMesg> records, int sessionId, int sessionStart, int sessionEnd)
		{
			List<LapMesg> lapsToRemove = new List<LapMesg>();

			foreach (LapMesg lap in laps)
			{
				int lapStart = Convert.ToInt32(lap.GetFieldValue(LapMesg.FieldDefNum.StartTime));
				if (lapStart < sessionStart || lapStart > sessionEnd) { continue; }

				int lapId = this.AddLap(lap, sessionId);
				lapsToRemove.Add(lap);

				if (lapId == -1) { continue; }

				int lapDuration = Int32F(lap, LapMesg.FieldDefNum.TotalElapsedTime) ?? 0;
				int lapEnd = lapStart + lapDuration;

				UploadRecords(records, lapId, lapStart, lapEnd);
			}

			foreach (LapMesg lap in lapsToRemove)
			{
				laps.Remove(lap);
			}
		}

		private void UploadRecords(List<RecordMesg> records, int lapId, int lapStart, int lapEnd)
		{
			List<RecordMesg> recordsToRemove = new List<RecordMesg>();

			foreach (RecordMesg record in records)
			{
				int recordStart = Convert.ToInt32(record.GetFieldValue(RecordMesg.FieldDefNum.Timestamp));
				if (recordStart < lapStart || recordStart > lapEnd) { continue; }

				AddRecord(record, lapId);

				recordsToRemove.Add(record);
			}

			foreach (RecordMesg record in recordsToRemove)
			{
				records.Remove(record);
			}
		}

		private int AddActivity(ActivityMesg mesg)
		{
			string query =
				"create table #temp (ID int); " +
				"insert Activity " +
				"output INSERTED.ID into #temp " +
				"values (" +
				"@Timestamp," +
				"@NumSessions," +
				"@ActivityType," +
				"@TotalTimerTime); " +
				"select * from #temp;" +
				"drop table if exists #temp;";

			using (SqlCommand cmd = new SqlCommand(query, conn))
			{
				cmd.Parameters.AddWithValue("@Timestamp", Int64N(mesg, ActivityMesg.FieldDefNum.Timestamp));
				cmd.Parameters.AddWithValue("@NumSessions", Int32N(mesg, ActivityMesg.FieldDefNum.NumSessions));
				cmd.Parameters.AddWithValue("@ActivityType", Int32N(mesg, ActivityMesg.FieldDefNum.Type));
				cmd.Parameters.AddWithValue("@TotalTimerTime", Int64N(mesg, ActivityMesg.FieldDefNum.TotalTimerTime));

				DataTable inserted = new DataTable("Inserted");
				SqlDataAdapter dap = new SqlDataAdapter(cmd);

				dap.Fill(inserted);

				foreach (DataRow row in inserted.Rows)
				{
					foreach (object item in row.ItemArray)
					{
						return Convert.ToInt32(item);
					}
				}
				return -1;
			}
		}

		private int AddSession(SessionMesg mesg, int activityId)
		{
			string query =
				"create table #temp (ID int); " +
				"insert Session " +
				"output INSERTED.ID into #temp " +
				"values (" +
				"@ActivityID," +
				"@Timestamp," +
				"@StartTime," +
				"@TotalElapsedTime," +
				"@TotalTimerTime," +
				"@AvgSpeed," +
				"@MaxSpeed," +
				"@TotalDistance," +
				"@AvgCadence," +
				"@MaxCadence," +
				"@AvgPower," +
				"@MaxPower," +
				"@LeftRightBalance," +
				"@TimeInPowerZone0," +
				"@TimeInPowerZone1," +
				"@TimeInPowerZone2," +
				"@TimeInPowerZone3," +
				"@TimeInPowerZone4," +
				"@TimeInPowerZone5," +
				"@TimeInPowerZone6," +
				"@TotalWork," +
				"@MinAltitude," +
				"@AvgAltitude," +
				"@MaxAltitude," +
				"@MaxNegGrade," +
				"@AvgGrade," +
				"@MaxPosGrade," +
				"@NormalizedPower," +
				"@AvgTemperature," +
				"@MaxTemperature," +
				"@TotalAscent," +
				"@TotalDescent," +
				"@Sport," +
				"@NumLaps," +
				"@ThresholdPower," +
				"@TrainingStressScore," +
				"@IntensityFactor," +
				"@EnhancedAvgSpeed," +
				"@EnhancedMaxSpeed," +
				"@EnhancedMinAltitude," +
				"@EnhancedAvgAltitude," +
				"@EnhancedMaxAltitude);" +
				"select * from #temp;" +
				"drop table if exists #temp;";

			using (SqlCommand cmd = new SqlCommand(query, conn))
			{
				cmd.Parameters.AddWithValue("@ActivityID", activityId);
				cmd.Parameters.AddWithValue("@Timestamp", Int64N(mesg, SessionMesg.FieldDefNum.Timestamp));
				cmd.Parameters.AddWithValue("@StartTime", Int64N(mesg, SessionMesg.FieldDefNum.StartTime));
				cmd.Parameters.AddWithValue("@TotalElapsedTime", Int64N(mesg, SessionMesg.FieldDefNum.TotalElapsedTime));
				cmd.Parameters.AddWithValue("@TotalTimerTime", Int64N(mesg, SessionMesg.FieldDefNum.TotalTimerTime));
				cmd.Parameters.AddWithValue("@AvgSpeed", Int32N(mesg, SessionMesg.FieldDefNum.AvgSpeed));
				cmd.Parameters.AddWithValue("@MaxSpeed", Int32N(mesg, SessionMesg.FieldDefNum.MaxSpeed));
				cmd.Parameters.AddWithValue("@TotalDistance", Int64N(mesg, SessionMesg.FieldDefNum.TotalDistance));
				cmd.Parameters.AddWithValue("@AvgCadence", Int32N(mesg, SessionMesg.FieldDefNum.AvgCadence));
				cmd.Parameters.AddWithValue("@MaxCadence", Int32N(mesg, SessionMesg.FieldDefNum.MaxCadence));
				cmd.Parameters.AddWithValue("@AvgPower", Int32N(mesg, SessionMesg.FieldDefNum.AvgPower));
				cmd.Parameters.AddWithValue("@MaxPower", Int32N(mesg, SessionMesg.FieldDefNum.MaxPower));
				cmd.Parameters.AddWithValue("@LeftRightBalance", Int32N(mesg, SessionMesg.FieldDefNum.LeftRightBalance));
				cmd.Parameters.AddWithValue("@TimeInPowerZone0", Int64N(mesg, SessionMesg.FieldDefNum.TimeInPowerZone, 0));
				cmd.Parameters.AddWithValue("@TimeInPowerZone1", Int64N(mesg, SessionMesg.FieldDefNum.TimeInPowerZone, 1));
				cmd.Parameters.AddWithValue("@TimeInPowerZone2", Int64N(mesg, SessionMesg.FieldDefNum.TimeInPowerZone, 2));
				cmd.Parameters.AddWithValue("@TimeInPowerZone3", Int64N(mesg, SessionMesg.FieldDefNum.TimeInPowerZone, 3));
				cmd.Parameters.AddWithValue("@TimeInPowerZone4", Int64N(mesg, SessionMesg.FieldDefNum.TimeInPowerZone, 4));
				cmd.Parameters.AddWithValue("@TimeInPowerZone5", Int64N(mesg, SessionMesg.FieldDefNum.TimeInPowerZone, 5));
				cmd.Parameters.AddWithValue("@TimeInPowerZone6", Int64N(mesg, SessionMesg.FieldDefNum.TimeInPowerZone, 6));
				cmd.Parameters.AddWithValue("@TotalWork", Int64N(mesg, SessionMesg.FieldDefNum.TotalWork));
				cmd.Parameters.AddWithValue("@MinAltitude", Int64N(mesg, SessionMesg.FieldDefNum.MinAltitude));
				cmd.Parameters.AddWithValue("@AvgAltitude", Int64N(mesg, SessionMesg.FieldDefNum.AvgAltitude));
				cmd.Parameters.AddWithValue("@MaxAltitude", Int64N(mesg, SessionMesg.FieldDefNum.MaxAltitude));
				cmd.Parameters.AddWithValue("@MaxNegGrade", Int32N(mesg, SessionMesg.FieldDefNum.MaxNegGrade));
				cmd.Parameters.AddWithValue("@AvgGrade", Int32N(mesg, SessionMesg.FieldDefNum.AvgGrade));
				cmd.Parameters.AddWithValue("@MaxPosGrade", Int32N(mesg, SessionMesg.FieldDefNum.MaxPosGrade));
				cmd.Parameters.AddWithValue("@NormalizedPower", Int32N(mesg, SessionMesg.FieldDefNum.NormalizedPower));
				cmd.Parameters.AddWithValue("@AvgTemperature", Int32N(mesg, SessionMesg.FieldDefNum.AvgTemperature));
				cmd.Parameters.AddWithValue("@MaxTemperature", Int32N(mesg, SessionMesg.FieldDefNum.MaxTemperature));
				cmd.Parameters.AddWithValue("@TotalAscent", Int64N(mesg, SessionMesg.FieldDefNum.TotalAscent));
				cmd.Parameters.AddWithValue("@TotalDescent", Int64N(mesg, SessionMesg.FieldDefNum.TotalDescent));
				cmd.Parameters.AddWithValue("@Sport", Int32N(mesg, SessionMesg.FieldDefNum.Sport));
				cmd.Parameters.AddWithValue("@NumLaps", Int32N(mesg, SessionMesg.FieldDefNum.NumLaps));
				cmd.Parameters.AddWithValue("@ThresholdPower", Int32N(mesg, SessionMesg.FieldDefNum.ThresholdPower));
				cmd.Parameters.AddWithValue("@TrainingStressScore", Int32N(mesg, SessionMesg.FieldDefNum.TrainingStressScore));
				cmd.Parameters.AddWithValue("@IntensityFactor", Int32N(mesg, SessionMesg.FieldDefNum.IntensityFactor));
				cmd.Parameters.AddWithValue("@EnhancedAvgSpeed", Int32N(mesg, SessionMesg.FieldDefNum.EnhancedAvgSpeed));
				cmd.Parameters.AddWithValue("@EnhancedMaxSpeed", Int32N(mesg, SessionMesg.FieldDefNum.EnhancedMaxSpeed));
				cmd.Parameters.AddWithValue("@EnhancedMinAltitude", Int64N(mesg, SessionMesg.FieldDefNum.EnhancedMinAltitude));
				cmd.Parameters.AddWithValue("@EnhancedAvgAltitude", Int64N(mesg, SessionMesg.FieldDefNum.EnhancedAvgAltitude));
				cmd.Parameters.AddWithValue("@EnhancedMaxAltitude", Int64N(mesg, SessionMesg.FieldDefNum.EnhancedMaxAltitude));

				DataTable inserted = new DataTable("Inserted");
				SqlDataAdapter dap = new SqlDataAdapter(cmd);

				dap.Fill(inserted);

				foreach (DataRow row in inserted.Rows)
				{
					foreach (object item in row.ItemArray)
					{
						return Convert.ToInt32(item);
					}
				}
				return -1;
			}
		}


		private int AddLap(LapMesg mesg, int sessionId)
		{
			string query =
				"create table #temp (ID int); " +
				"insert Lap " +
				"output INSERTED.ID into #temp " +
				"values (" +
				"@SessionID," +
				"@Timestamp," +
				"@StartTime," +
				"@TotalElapsedTime," +
				"@TotalTimerTime," +
				"@AvgSpeed," +
				"@MaxSpeed," +
				"@TotalDistance," +
				"@AvgCadence," +
				"@MaxCadence," +
				"@AvgPower," +
				"@MaxPower," +
				"@LeftRightBalance," +
				"@TimeInPowerZone0," +
				"@TimeInPowerZone1," +
				"@TimeInPowerZone2," +
				"@TimeInPowerZone3," +
				"@TimeInPowerZone4," +
				"@TimeInPowerZone5," +
				"@TimeInPowerZone6," +
				"@TotalWork," +
				"@MinAltitude," +
				"@AvgAltitude," +
				"@MaxAltitude," +
				"@MaxNegGrade," +
				"@AvgGrade," +
				"@MaxPosGrade," +
				"@NormalizedPower," +
				"@AvgTemperature," +
				"@MaxTemperature," +
				"@TotalAscent," +
				"@TotalDescent," +
				"@EnhancedAvgSpeed," +
				"@EnhancedMaxSpeed," +
				"@EnhancedMinAltitude," +
				"@EnhancedAvgAltitude," +
				"@EnhancedMaxAltitude);" +
				"select * from #temp;" +
				"drop table if exists #temp;";

			using (SqlCommand cmd = new SqlCommand(query, conn))
			{
				cmd.Parameters.AddWithValue("@SessionID", sessionId);
				cmd.Parameters.AddWithValue("@Timestamp", Int64N(mesg, LapMesg.FieldDefNum.Timestamp));
				cmd.Parameters.AddWithValue("@StartTime", Int64N(mesg, LapMesg.FieldDefNum.StartTime));
				cmd.Parameters.AddWithValue("@TotalElapsedTime", Int64N(mesg, LapMesg.FieldDefNum.TotalElapsedTime));
				cmd.Parameters.AddWithValue("@TotalTimerTime", Int64N(mesg, LapMesg.FieldDefNum.TotalTimerTime));
				cmd.Parameters.AddWithValue("@AvgSpeed", Int32N(mesg, LapMesg.FieldDefNum.AvgSpeed));
				cmd.Parameters.AddWithValue("@MaxSpeed", Int32N(mesg, LapMesg.FieldDefNum.MaxSpeed));
				cmd.Parameters.AddWithValue("@TotalDistance", Int64N(mesg, LapMesg.FieldDefNum.TotalDistance));
				cmd.Parameters.AddWithValue("@AvgCadence", Int32N(mesg, LapMesg.FieldDefNum.AvgCadence));
				cmd.Parameters.AddWithValue("@MaxCadence", Int32N(mesg, LapMesg.FieldDefNum.MaxCadence));
				cmd.Parameters.AddWithValue("@AvgPower", Int32N(mesg, LapMesg.FieldDefNum.AvgPower));
				cmd.Parameters.AddWithValue("@MaxPower", Int32N(mesg, LapMesg.FieldDefNum.MaxPower));
				cmd.Parameters.AddWithValue("@LeftRightBalance", Int32N(mesg, LapMesg.FieldDefNum.LeftRightBalance));
				cmd.Parameters.AddWithValue("@TimeInPowerZone0", Int64N(mesg, LapMesg.FieldDefNum.TimeInPowerZone, 0));
				cmd.Parameters.AddWithValue("@TimeInPowerZone1", Int64N(mesg, LapMesg.FieldDefNum.TimeInPowerZone, 1));
				cmd.Parameters.AddWithValue("@TimeInPowerZone2", Int64N(mesg, LapMesg.FieldDefNum.TimeInPowerZone, 2));
				cmd.Parameters.AddWithValue("@TimeInPowerZone3", Int64N(mesg, LapMesg.FieldDefNum.TimeInPowerZone, 3));
				cmd.Parameters.AddWithValue("@TimeInPowerZone4", Int64N(mesg, LapMesg.FieldDefNum.TimeInPowerZone, 4));
				cmd.Parameters.AddWithValue("@TimeInPowerZone5", Int64N(mesg, LapMesg.FieldDefNum.TimeInPowerZone, 5));
				cmd.Parameters.AddWithValue("@TimeInPowerZone6", Int64N(mesg, LapMesg.FieldDefNum.TimeInPowerZone, 6));
				cmd.Parameters.AddWithValue("@TotalWork", Int64N(mesg, LapMesg.FieldDefNum.TotalWork));
				cmd.Parameters.AddWithValue("@MinAltitude", Int64N(mesg, LapMesg.FieldDefNum.MinAltitude));
				cmd.Parameters.AddWithValue("@AvgAltitude", Int64N(mesg, LapMesg.FieldDefNum.AvgAltitude));
				cmd.Parameters.AddWithValue("@MaxAltitude", Int64N(mesg, LapMesg.FieldDefNum.MaxAltitude));
				cmd.Parameters.AddWithValue("@MaxNegGrade", Int32N(mesg, LapMesg.FieldDefNum.MaxNegGrade));
				cmd.Parameters.AddWithValue("@AvgGrade", Int32N(mesg, LapMesg.FieldDefNum.AvgGrade));
				cmd.Parameters.AddWithValue("@MaxPosGrade", Int32N(mesg, LapMesg.FieldDefNum.MaxPosGrade));
				cmd.Parameters.AddWithValue("@NormalizedPower", Int32N(mesg, LapMesg.FieldDefNum.NormalizedPower));
				cmd.Parameters.AddWithValue("@AvgTemperature", Int32N(mesg, LapMesg.FieldDefNum.AvgTemperature));
				cmd.Parameters.AddWithValue("@MaxTemperature", Int32N(mesg, LapMesg.FieldDefNum.MaxTemperature));
				cmd.Parameters.AddWithValue("@TotalAscent", Int64N(mesg, LapMesg.FieldDefNum.TotalAscent));
				cmd.Parameters.AddWithValue("@TotalDescent", Int64N(mesg, LapMesg.FieldDefNum.TotalDescent));
				cmd.Parameters.AddWithValue("@EnhancedAvgSpeed", Int32N(mesg, LapMesg.FieldDefNum.EnhancedAvgSpeed));
				cmd.Parameters.AddWithValue("@EnhancedMaxSpeed", Int32N(mesg, LapMesg.FieldDefNum.EnhancedMaxSpeed));
				cmd.Parameters.AddWithValue("@EnhancedMinAltitude", Int64N(mesg, LapMesg.FieldDefNum.EnhancedMinAltitude));
				cmd.Parameters.AddWithValue("@EnhancedAvgAltitude", Int64N(mesg, LapMesg.FieldDefNum.EnhancedAvgAltitude));
				cmd.Parameters.AddWithValue("@EnhancedMaxAltitude", Int64N(mesg, LapMesg.FieldDefNum.EnhancedMaxAltitude));

				DataTable inserted = new DataTable("Inserted");
				SqlDataAdapter dap = new SqlDataAdapter(cmd);

				dap.Fill(inserted);

				foreach (DataRow row in inserted.Rows)
				{
					foreach (object item in row.ItemArray)
					{
						return Convert.ToInt32(item);
					}
				}
				return -1;
			}
		}

		private int AddRecord(RecordMesg mesg, int lapId)
		{
			string query =
				"create table #temp (ID int); " +
				"insert Record " +
				"output INSERTED.ID into #temp " +
				"values (" +
				"@LapID," +
				"@Timestamp," +
				"@PositionLat," +
				"@PositionLong," +
				"@GpsAccuracy," +
				"@Distance," +
				"@Altitude," +
				"@Grade," +
				"@Cadence," +
				"@Speed," +
				"@Power," +
				"@LeftRightBalance," +
				"@LeftPedalSmoothness," +
				"@RightPedalSmoothness," +
				"@LeftTorqueEffectiveness," +
				"@RightTorqueEffectiveness," +
				"@Temperature," +
				"@EnhancedAltitude," +
				"@EnhancedSpeed); " +
				"select * from #temp;" +
				"drop table if exists #temp;";

			using (SqlCommand cmd = new SqlCommand(query, conn))
			{
				cmd.Parameters.AddWithValue("@LapID", lapId);
				cmd.Parameters.AddWithValue("@Timestamp", Int64N(mesg, RecordMesg.FieldDefNum.Timestamp));
				cmd.Parameters.AddWithValue("@PositionLat", Int64N(mesg, RecordMesg.FieldDefNum.PositionLat));
				cmd.Parameters.AddWithValue("@PositionLong", Int64N(mesg, RecordMesg.FieldDefNum.PositionLong));
				cmd.Parameters.AddWithValue("@GpsAccuracy", Int32N(mesg, RecordMesg.FieldDefNum.GpsAccuracy));
				cmd.Parameters.AddWithValue("@Distance", Int64N(mesg, RecordMesg.FieldDefNum.Distance));
				cmd.Parameters.AddWithValue("@Altitude", Int64N(mesg, RecordMesg.FieldDefNum.Altitude));
				cmd.Parameters.AddWithValue("@Grade", Int64N(mesg, RecordMesg.FieldDefNum.Grade));
				cmd.Parameters.AddWithValue("@Cadence", Int32N(mesg, RecordMesg.FieldDefNum.Cadence));
				cmd.Parameters.AddWithValue("@Speed", Int32N(mesg, RecordMesg.FieldDefNum.Speed));
				cmd.Parameters.AddWithValue("@Power", Int32N(mesg, RecordMesg.FieldDefNum.Power));
				cmd.Parameters.AddWithValue("@LeftRightBalance", Int32N(mesg, RecordMesg.FieldDefNum.LeftRightBalance));
				cmd.Parameters.AddWithValue("@LeftPedalSmoothness", Int32N(mesg, RecordMesg.FieldDefNum.LeftPedalSmoothness));
				cmd.Parameters.AddWithValue("@RightPedalSmoothness", Int32N(mesg, RecordMesg.FieldDefNum.RightPedalSmoothness));
				cmd.Parameters.AddWithValue("@LeftTorqueEffectiveness", Int32N(mesg, RecordMesg.FieldDefNum.LeftTorqueEffectiveness));
				cmd.Parameters.AddWithValue("@RightTorqueEffectiveness", Int32N(mesg, RecordMesg.FieldDefNum.RightTorqueEffectiveness));
				cmd.Parameters.AddWithValue("@Temperature", Int32N(mesg, RecordMesg.FieldDefNum.Temperature));
				cmd.Parameters.AddWithValue("@EnhancedAltitude", Int64N(mesg, RecordMesg.FieldDefNum.EnhancedAltitude));
				cmd.Parameters.AddWithValue("@EnhancedSpeed", Int32N(mesg, RecordMesg.FieldDefNum.EnhancedSpeed));

				DataTable inserted = new DataTable("Inserted");
				SqlDataAdapter dap = new SqlDataAdapter(cmd);

				dap.Fill(inserted);

				foreach (DataRow row in inserted.Rows)
				{
					foreach (object item in row.ItemArray)
					{
						return Convert.ToInt32(item);
					}
				}
				return -1;
			}
		}

		public void Close()
		{
			conn.Close();
		}

		private Int32? Int32F(Mesg s, byte f, int v = 0)
		{
			try
			{
				object value = GetValue(s, f, v);
				if (value == null) return null;

				return Convert.ToInt32(value);
			}
			catch
			{
				return null;
			}
		}

		private object Int32N(Mesg s, byte f, int v = 0)
		{
			return (object)Int32F(s, f, v) ?? DBNull.Value;
		}

		private Int64? Int64F(Mesg s, byte f, int v = 0)
		{
			try
			{
				object value = GetValue(s, f, v);
				if (value == null) return null;

				return Convert.ToInt64(value);
			}
			catch
			{
				return null;
			}
		}

		private object Int64N(Mesg s, byte f, int v = 0)
		{
			return (object)Int64F(s, f, v) ?? DBNull.Value;
		}

		private object GetValue(Mesg s, byte f, int v = 0)
		{
			Field field = s.GetField(f);
			if (field == null) { return null; }

			object value = field.GetRawValue(v);
			return value;
		}
	}
}