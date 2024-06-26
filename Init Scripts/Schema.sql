USE [master]
GO
/****** Object:  Database [CYCLING]    Script Date: 2019/10/20 6:24:13 PM ******/
CREATE DATABASE [CYCLING]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'CYCLING', FILENAME = N'/var/opt/mssql/data/CYCLING.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'CYCLING_log', FILENAME = N'/var/opt/mssql/data/CYCLING_log.ldf' , SIZE = 335872KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [CYCLING] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [CYCLING].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [CYCLING] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [CYCLING] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [CYCLING] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [CYCLING] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [CYCLING] SET ARITHABORT OFF 
GO
ALTER DATABASE [CYCLING] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [CYCLING] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [CYCLING] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [CYCLING] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [CYCLING] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [CYCLING] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [CYCLING] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [CYCLING] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [CYCLING] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [CYCLING] SET  DISABLE_BROKER 
GO
ALTER DATABASE [CYCLING] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [CYCLING] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [CYCLING] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [CYCLING] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [CYCLING] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [CYCLING] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [CYCLING] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [CYCLING] SET RECOVERY FULL 
GO
ALTER DATABASE [CYCLING] SET  MULTI_USER 
GO
ALTER DATABASE [CYCLING] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [CYCLING] SET DB_CHAINING OFF 
GO
ALTER DATABASE [CYCLING] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [CYCLING] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [CYCLING] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [CYCLING] SET QUERY_STORE = OFF
GO
USE [CYCLING]
GO
/****** Object:  Table [dbo].[Record]    Script Date: 2019/10/20 6:24:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Record](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Lap_ID] [int] NULL,
	[Timestamp] [bigint] NULL,
	[PositionLat] [bigint] NULL,
	[PositionLong] [bigint] NULL,
	[GpsAccuracy] [int] NULL,
	[Distance] [bigint] NULL,
	[Altitude] [bigint] NULL,
	[Grade] [int] NULL,
	[Cadence] [int] NULL,
	[Speed] [int] NULL,
	[Power] [int] NULL,
	[LeftRightBalance] [int] NULL,
	[LeftPedalSmoothness] [int] NULL,
	[RightPedalSmoothness] [int] NULL,
	[LeftTorqueEffectiveness] [int] NULL,
	[RightTorqueEffectiveness] [int] NULL,
	[Temperature] [int] NULL,
	[EnhancedAltitude] [bigint] NULL,
	[EnhancedSpeed] [int] NULL,
 CONSTRAINT [PK_Record] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[V_Record]    Script Date: 2019/10/20 6:24:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_Record]
AS
SELECT        ID, Lap_ID, DATEADD(ss, Timestamp, CAST('19891231' AS DateTime)) AS Timestamp_DT_UTC, PositionLat, PositionLong, GpsAccuracy, CAST(Distance AS decimal(32, 6)) / 100000 AS Distance_KM, CAST(Altitude AS decimal(18, 
                         2)) / 5 - 500 AS Altitude_M, CAST(Grade AS decimal(18, 6)) / 100 AS Grade_Deg, Cadence, CAST(Speed AS decimal(32, 6)) / 1000000 * 3600 AS Speed_KPH, Power, LeftRightBalance, CAST(LeftPedalSmoothness AS decimal(18, 2)) 
                         / 2 AS LeftPedalSmoothness_Pct, CAST(RightPedalSmoothness AS decimal(18, 2)) / 2 AS RightPedalSmoothness_Pct, CAST(LeftTorqueEffectiveness AS decimal(18, 2)) / 2 AS LeftTorqueEffectiveness_Pct, 
                         CAST(RightTorqueEffectiveness AS decimal(18, 2)) / 2 AS RightTorqueEffectiveness_Pct, Temperature, CAST(EnhancedAltitude AS decimal(18, 2)) / 5 - 500 AS EnhancedAltitude_M, CAST(EnhancedSpeed AS decimal(32, 6)) 
                         / 1000000 * 3600 AS EnhancedSpeed_KPH
FROM            dbo.Record
GO
/****** Object:  Table [dbo].[ActivityType]    Script Date: 2019/10/20 6:24:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActivityType](
	[ID] [int] NOT NULL,
	[Name] [nchar](30) NULL,
 CONSTRAINT [PK_ActivityType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Activity]    Script Date: 2019/10/20 6:24:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Activity](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Timestamp] [bigint] NULL,
	[NumSessions] [int] NULL,
	[ActivityType_ID] [int] NULL,
	[TotalTimerTime] [bigint] NULL,
 CONSTRAINT [PK_Activity] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Session]    Script Date: 2019/10/20 6:24:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Session](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Activity_ID] [int] NULL,
	[Timestamp] [bigint] NULL,
	[StartTime] [bigint] NULL,
	[TotalElapsedTime] [bigint] NULL,
	[TotalTimerTime] [bigint] NULL,
	[AvgSpeed] [int] NULL,
	[MaxSpeed] [int] NULL,
	[TotalDistance] [bigint] NULL,
	[AvgCadence] [int] NULL,
	[MaxCadence] [int] NULL,
	[AvgPower] [int] NULL,
	[MaxPower] [int] NULL,
	[LeftRightBalance] [int] NULL,
	[TimeInPowerZone0] [bigint] NULL,
	[TimeInPowerZone1] [bigint] NULL,
	[TimeInPowerZone2] [bigint] NULL,
	[TimeInPowerZone3] [bigint] NULL,
	[TimeInPowerZone4] [bigint] NULL,
	[TimeInPowerZone5] [bigint] NULL,
	[TimeInPowerZone6] [bigint] NULL,
	[TotalWork] [bigint] NULL,
	[MinAltitude] [bigint] NULL,
	[AvgAltitude] [bigint] NULL,
	[MaxAltitude] [bigint] NULL,
	[MaxNegGrade] [int] NULL,
	[AvgGrade] [int] NULL,
	[MaxPosGrade] [int] NULL,
	[NormalizedPower] [int] NULL,
	[AvgTemperature] [int] NULL,
	[MaxTemperature] [int] NULL,
	[TotalAscent] [bigint] NULL,
	[TotalDescent] [bigint] NULL,
	[Sport_ID] [int] NULL,
	[NumLaps] [int] NULL,
	[ThresholdPower] [int] NULL,
	[TrainingStressScore] [int] NULL,
	[IntensityFactor] [int] NULL,
	[EnhancedAvgSpeed] [int] NULL,
	[EnhancedMaxSpeed] [int] NULL,
	[EnhancedMinAltitude] [bigint] NULL,
	[EnhancedAvgAltitude] [bigint] NULL,
	[EnhancedMaxAltitude] [bigint] NULL,
 CONSTRAINT [PK_Session] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[V_Activity]    Script Date: 2019/10/20 6:24:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_Activity]
AS
SELECT        dbo.Activity.ID, DATEADD(ss, dbo.Activity.Timestamp - dbo.Activity.TotalTimerTime / 1000, CAST('19891231' AS DateTime)) AS ActivityStartTime_DT_UTC, DATEADD(ss, dbo.Activity.Timestamp, CAST('19891231' AS DateTime)) 
                         AS ActivityEndTime_DT_UTC, dbo.Activity.NumSessions, dbo.Activity.ActivityType_ID, dbo.ActivityType.Name AS ActivityType, CAST(dbo.Activity.TotalTimerTime AS decimal(18, 3)) / 1000 AS TotalTimerTime_Sec, 
                         SUM(CAST(dbo.Session.TotalDistance AS decimal(32, 6)) / 100000) AS TotalDistance_KM
FROM            dbo.Activity INNER JOIN
                         dbo.ActivityType ON dbo.Activity.ActivityType_ID = dbo.ActivityType.ID INNER JOIN
                         dbo.Session ON dbo.Activity.ID = dbo.Session.Activity_ID
GROUP BY dbo.Activity.ID, DATEADD(ss, dbo.Activity.Timestamp - dbo.Activity.TotalTimerTime / 1000, CAST('19891231' AS DateTime)), DATEADD(ss, dbo.Activity.Timestamp, CAST('19891231' AS DateTime)), dbo.Activity.NumSessions, 
                         dbo.Activity.ActivityType_ID, dbo.ActivityType.Name, CAST(dbo.Activity.TotalTimerTime AS decimal(18, 3)) / 1000
GO
/****** Object:  Table [dbo].[Sport]    Script Date: 2019/10/20 6:24:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sport](
	[ID] [int] NOT NULL,
	[Name] [nchar](30) NULL,
 CONSTRAINT [PK_Table_3] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[V_Session]    Script Date: 2019/10/20 6:24:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_Session]
AS
SELECT        dbo.Session.ID, dbo.Session.Activity_ID, DATEADD(ss, dbo.Session.Timestamp, CAST('19891231' AS DateTime)) AS Timestamp_DT_UTC, DATEADD(ss, dbo.Session.StartTime, CAST('19891231' AS DateTime)) 
                         AS StartTime_DT_UTC, CAST(dbo.Session.TotalElapsedTime AS decimal(18, 3)) / 1000 AS TotalElapsedTime_Sec, CAST(dbo.Session.TotalTimerTime AS decimal(18, 3)) / 1000 AS TotalTimerTime_Sec, 
                         CAST(dbo.Session.AvgSpeed AS decimal(32, 6)) / 1000000 * 3600 AS AvgSpeed_KMH, CAST(dbo.Session.MaxSpeed AS decimal(32, 6)) / 1000000 * 3600 AS MaxSpeed_KMH, CAST(dbo.Session.TotalDistance AS decimal(32, 6)) 
                         / 100000 AS TotalDistance_KM, dbo.Session.AvgCadence, dbo.Session.MaxCadence, dbo.Session.AvgPower, dbo.Session.MaxPower, dbo.Session.LeftRightBalance, CAST(dbo.Session.TimeInPowerZone0 AS decimal(18, 3)) 
                         / 1000 AS TimeInPowerZone0_Sec, CAST(dbo.Session.TimeInPowerZone1 AS decimal(18, 3)) / 1000 AS TimeInPowerZone1_Sec, CAST(dbo.Session.TimeInPowerZone2 AS decimal(18, 3)) / 1000 AS TimeInPowerZone2_Sec, 
                         CAST(dbo.Session.TimeInPowerZone3 AS decimal(18, 3)) / 1000 AS TimeInPowerZone3_Sec, CAST(dbo.Session.TimeInPowerZone4 AS decimal(18, 3)) / 1000 AS TimeInPowerZone4_Sec, 
                         CAST(dbo.Session.TimeInPowerZone5 AS decimal(18, 3)) / 1000 AS TimeInPowerZone5_Sec, CAST(dbo.Session.TimeInPowerZone6 AS decimal(18, 3)) / 1000 AS TimeInPowerZone6_Sec, dbo.Session.TotalWork, 
                         CAST(dbo.Session.MinAltitude AS decimal(18, 2)) / 5 - 500 AS MinAltitude_M, CAST(dbo.Session.AvgAltitude AS decimal(18, 2)) / 5 - 500 AS AvgAltitude_M, CAST(dbo.Session.MaxAltitude AS decimal(18, 2)) 
                         / 5 - 500 AS MaxAltitude_M, CAST(dbo.Session.MaxNegGrade AS decimal(18, 6)) / 100 AS MaxNegGrade_Deg, CAST(dbo.Session.AvgGrade AS decimal(18, 6)) / 100 AS AvgGrade_Deg, 
                         CAST(dbo.Session.MaxPosGrade AS decimal(18, 6)) / 100 AS MaxPosGrade_Deg, dbo.Session.NormalizedPower, dbo.Session.AvgTemperature, dbo.Session.MaxTemperature, dbo.Session.TotalAscent AS TotalAscent_M, 
                         dbo.Session.TotalDescent AS TotalDescent_M, dbo.Session.Sport_ID, dbo.Sport.Name AS SportName, dbo.Session.NumLaps, dbo.Session.ThresholdPower, CAST(dbo.Session.TrainingStressScore AS decimal(18, 2)) 
                         / 100 AS TrainingStressScore, CAST(dbo.Session.IntensityFactor AS decimal(18, 3)) / 1000 AS IntensityFactor, CAST(dbo.Session.EnhancedAvgSpeed AS decimal(32, 6)) / 1000000 * 3600 AS EnhancedAvgSpeed_KMH, 
                         CAST(dbo.Session.EnhancedMaxSpeed AS decimal(32, 6)) / 1000000 * 3600 AS EnhancedMaxSpeed_KMH, CAST(dbo.Session.EnhancedMinAltitude AS decimal(18, 2)) / 5 - 500 AS EnhancedMinAltitude_M, 
                         CAST(dbo.Session.EnhancedAvgAltitude AS decimal(18, 2)) / 5 - 500 AS EnhancedAvgAltitude_M, CAST(dbo.Session.EnhancedMaxAltitude AS decimal(18, 2)) / 5 - 500 AS EnhancedMaxAltitude_M
FROM            dbo.Session INNER JOIN
                         dbo.Sport ON dbo.Session.Sport_ID = dbo.Sport.ID
GO
/****** Object:  Table [dbo].[Lap]    Script Date: 2019/10/20 6:24:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lap](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Session_ID] [int] NULL,
	[Timestamp] [bigint] NULL,
	[StartTime] [bigint] NULL,
	[TotalElapsedTime] [bigint] NULL,
	[TotalTimerTime] [bigint] NULL,
	[AvgSpeed] [int] NULL,
	[MaxSpeed] [int] NULL,
	[TotalDistance] [bigint] NULL,
	[AvgCadence] [int] NULL,
	[MaxCadence] [int] NULL,
	[AvgPower] [int] NULL,
	[MaxPower] [int] NULL,
	[LeftRightBalance] [int] NULL,
	[TimeInPowerZone0] [bigint] NULL,
	[TimeInPowerZone1] [bigint] NULL,
	[TimeInPowerZone2] [bigint] NULL,
	[TimeInPowerZone3] [bigint] NULL,
	[TimeInPowerZone4] [bigint] NULL,
	[TimeInPowerZone5] [bigint] NULL,
	[TimeInPowerZone6] [bigint] NULL,
	[TotalWork] [bigint] NULL,
	[MinAltitude] [bigint] NULL,
	[AvgAltitude] [bigint] NULL,
	[MaxAltitude] [bigint] NULL,
	[MaxNegGrade] [int] NULL,
	[AvgGrade] [int] NULL,
	[MaxPosGrade] [int] NULL,
	[NormalizedPower] [int] NULL,
	[AvgTemperature] [int] NULL,
	[MaxTemperature] [int] NULL,
	[TotalAscent] [bigint] NULL,
	[TotalDescent] [bigint] NULL,
	[EnhancedAvgSpeed] [int] NULL,
	[EnhancedMaxSpeed] [int] NULL,
	[EnhancedMinAltitude] [bigint] NULL,
	[EnhancedAvgAltitude] [bigint] NULL,
	[EnhancedMaxAltitude] [bigint] NULL,
 CONSTRAINT [PK_Lap] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[V_Lap]    Script Date: 2019/10/20 6:24:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_Lap]
AS
SELECT        ID, Session_ID, DATEADD(ss, Timestamp, CAST('19891231' AS DateTime)) AS Timestamp_DT_UTC, DATEADD(ss, StartTime, CAST('19891231' AS DateTime)) AS StartTime_DT_UTC, CAST(TotalElapsedTime AS decimal(18, 3)) 
                         / 1000 AS TotalElapsedTime_Sec, CAST(TotalTimerTime AS decimal(18, 3)) / 1000 AS TotalTimerTime_Sec, CAST(AvgSpeed AS decimal(32, 6)) / 1000000 * 3600 AS AvgSpeed_KMH, CAST(MaxSpeed AS decimal(32, 6)) 
                         / 1000000 * 3600 AS MaxSpeed_KMH, CAST(TotalDistance AS decimal(32, 6)) / 100000 AS TotalDistance_KM, AvgCadence, MaxCadence, AvgPower, MaxPower, LeftRightBalance, CAST(TimeInPowerZone0 AS decimal(18, 3)) 
                         / 1000 AS TimeInPowerZone0_Sec, CAST(TimeInPowerZone1 AS decimal(18, 3)) / 1000 AS TimeInPowerZone1_Sec, CAST(TimeInPowerZone2 AS decimal(18, 3)) / 1000 AS TimeInPowerZone2_Sec, 
                         CAST(TimeInPowerZone3 AS decimal(18, 3)) / 1000 AS TimeInPowerZone3_Sec, CAST(TimeInPowerZone4 AS decimal(18, 3)) / 1000 AS TimeInPowerZone4_Sec, CAST(TimeInPowerZone5 AS decimal(18, 3)) 
                         / 1000 AS TimeInPowerZone5_Sec, CAST(TimeInPowerZone6 AS decimal(18, 3)) / 1000 AS TimeInPowerZone6_Sec, TotalWork, CAST(MinAltitude AS decimal(18, 2)) / 5 - 500 AS MinAltitude_M, CAST(AvgAltitude AS decimal(18, 2)) 
                         / 5 - 500 AS AvgAltitude_M, CAST(MaxAltitude AS decimal(18, 2)) / 5 - 500 AS MaxAltitude_M, CAST(MaxNegGrade AS decimal(18, 6)) / 100 AS MaxNegGrade_Deg, CAST(AvgGrade AS decimal(18, 6)) / 100 AS AvgGrade_Deg, 
                         CAST(MaxPosGrade AS decimal(18, 6)) / 100 AS MaxPosGrade_Deg, NormalizedPower, AvgTemperature, MaxTemperature, TotalAscent AS TotalAscent_M, TotalDescent AS TotalDescent_M, 
                         CAST(EnhancedAvgSpeed AS decimal(32, 6)) / 1000000 * 3600 AS EnhancedAvgSpeed_KMH, CAST(EnhancedMaxSpeed AS decimal(32, 6)) / 1000000 * 3600 AS EnhancedMaxSpeed_KMH, 
                         CAST(EnhancedMinAltitude AS decimal(18, 2)) / 5 - 500 AS EnhancedMinAltitude_M, CAST(EnhancedAvgAltitude AS decimal(18, 2)) / 5 - 500 AS EnhancedAvgAltitude_M, CAST(EnhancedMaxAltitude AS decimal(18, 2)) 
                         / 5 - 500 AS EnhancedMaxAltitude_M
FROM            dbo.Lap
GO
ALTER TABLE [dbo].[Activity]  WITH CHECK ADD  CONSTRAINT [FK_Activity_ActivityType] FOREIGN KEY([ActivityType_ID])
REFERENCES [dbo].[ActivityType] ([ID])
GO
ALTER TABLE [dbo].[Activity] CHECK CONSTRAINT [FK_Activity_ActivityType]
GO
ALTER TABLE [dbo].[Lap]  WITH CHECK ADD  CONSTRAINT [FK_Lap_Session] FOREIGN KEY([Session_ID])
REFERENCES [dbo].[Session] ([ID])
GO
ALTER TABLE [dbo].[Lap] CHECK CONSTRAINT [FK_Lap_Session]
GO
ALTER TABLE [dbo].[Record]  WITH CHECK ADD  CONSTRAINT [FK_Record_Lap] FOREIGN KEY([Lap_ID])
REFERENCES [dbo].[Lap] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Record] CHECK CONSTRAINT [FK_Record_Lap]
GO
ALTER TABLE [dbo].[Session]  WITH CHECK ADD  CONSTRAINT [FK_Session_Activity] FOREIGN KEY([Activity_ID])
REFERENCES [dbo].[Activity] ([ID])
GO
ALTER TABLE [dbo].[Session] CHECK CONSTRAINT [FK_Session_Activity]
GO
ALTER TABLE [dbo].[Session]  WITH CHECK ADD  CONSTRAINT [FK_Session_Sport] FOREIGN KEY([Sport_ID])
REFERENCES [dbo].[Sport] ([ID])
GO
ALTER TABLE [dbo].[Session] CHECK CONSTRAINT [FK_Session_Sport]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Records are snapshots of metrics taken throughout a ride.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Record'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Activity"
            Begin Extent = 
               Top = 3
               Left = 235
               Bottom = 133
               Right = 406
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "ActivityType"
            Begin Extent = 
               Top = 7
               Left = 17
               Bottom = 103
               Right = 187
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Session"
            Begin Extent = 
               Top = 6
               Left = 455
               Bottom = 136
               Right = 661
            End
            DisplayFlags = 280
            TopColumn = 2
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 2475
         Width = 2610
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 4245
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_Activity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_Activity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Lap"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 34
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 3720
         Alias = 3420
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_Lap'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_Lap'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Record"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 260
            End
            DisplayFlags = 280
            TopColumn = 16
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 21
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 5190
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_Record'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_Record'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Session"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 39
         End
         Begin Table = "Sport"
            Begin Extent = 
               Top = 6
               Left = 282
               Bottom = 102
               Right = 452
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 45
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Colum' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_Session'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'n = 4770
         Alias = 2775
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_Session'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_Session'
GO
USE [master]
GO
ALTER DATABASE [CYCLING] SET  READ_WRITE 
GO
