USE [master]
GO
DROP DATABASE IF EXISTS [PrivateSchool]
GO
/****** Object:  Database [PrivateSchool]    Script Date: 18-Nov-19 5:16:24 PM ******/
CREATE DATABASE [PrivateSchool]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'PrivateSchool', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\PrivateSchool.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'PrivateSchool_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\PrivateSchool_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [PrivateSchool] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [PrivateSchool].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [PrivateSchool] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [PrivateSchool] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [PrivateSchool] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [PrivateSchool] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [PrivateSchool] SET ARITHABORT OFF 
GO
ALTER DATABASE [PrivateSchool] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [PrivateSchool] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [PrivateSchool] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [PrivateSchool] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [PrivateSchool] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [PrivateSchool] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [PrivateSchool] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [PrivateSchool] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [PrivateSchool] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [PrivateSchool] SET  DISABLE_BROKER 
GO
ALTER DATABASE [PrivateSchool] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [PrivateSchool] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [PrivateSchool] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [PrivateSchool] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [PrivateSchool] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [PrivateSchool] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [PrivateSchool] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [PrivateSchool] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [PrivateSchool] SET  MULTI_USER 
GO
ALTER DATABASE [PrivateSchool] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [PrivateSchool] SET DB_CHAINING OFF 
GO
ALTER DATABASE [PrivateSchool] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [PrivateSchool] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [PrivateSchool] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [PrivateSchool] SET QUERY_STORE = OFF
GO
USE [PrivateSchool]
GO
/****** Object:  UserDefinedFunction [dbo].[IsValidAssignmentPerCoursePerStudent]    Script Date: 18-Nov-19 5:16:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[IsValidAssignmentPerCoursePerStudent](@AssignmentId int, @CourseId int, @StudentId int) 
RETURNS bit
AS
BEGIN
	DECLARE @CheckStudentIdCourseId int;
	DECLARE @CheckAssignmentIdCourseId int;
	DECLARE @return bit;

	SELECT @CheckStudentIdCourseId = COUNT(*) FROM StudentsPerCourse WHERE StudentId = @StudentId AND CourseId = @CourseId;
	SELECT @CheckAssignmentIdCourseId = COUNT(*) FROM AssignmentsPerCourse WHERE AssignmentId = @AssignmentId AND CourseId = @CourseId;

	IF (@CheckStudentIdCourseId = 0 OR @CheckAssignmentIdCourseId = 0)
		SET @return = 'false'
	ELSE
		SET @return = 'true'
	
	RETURN @return;

END
GO
/****** Object:  UserDefinedFunction [dbo].[IsValidStudentsOralMark]    Script Date: 18-Nov-19 5:16:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[IsValidStudentsOralMark](@StudentsOralMark float, @AssignmentsId int)
RETURNS bit
AS
BEGIN
	-- Declare the return variable here
	DECLARE @AssignmentsMaxOralMark float;
	DECLARE @return bit;

	-- Add the T-SQL statements to compute the return value here
	SELECT @AssignmentsMaxOralMark = Assignments.OralMark FROM Assignments
	WHERE Assignments.AssignmentId = @AssignmentsId

	IF (@StudentsOralMark > @AssignmentsMaxOralMark)
	SET @return = 'false';
    ELSE
    SET @return = 'true';

	-- Return the result of the function
	RETURN @return;

END
GO
/****** Object:  UserDefinedFunction [dbo].[IsValidStudentsTotalMark]    Script Date: 18-Nov-19 5:16:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[IsValidStudentsTotalMark](@StudentsTotalMark float, @StudentsOralMark float, @AssignmentsId int)
RETURNS bit
AS
BEGIN
	-- Declare the return variable here
	DECLARE @AssignmentsMaxOralMark float;
	DECLARE @AssignmentsMaxTotalMark float;
	DECLARE @return bit;

	-- Add the T-SQL statements to compute the return value here
	SELECT @AssignmentsMaxOralMark = Assignments.OralMark, @AssignmentsMaxTotalMark = Assignments.TotalMark FROM Assignments
	WHERE Assignments.AssignmentId = @AssignmentsId

	IF (@StudentsTotalMark > @AssignmentsMaxTotalMark)
	SET @return = 'false';
	ELSE IF (@StudentsTotalMark > @AssignmentsMaxTotalMark - (@AssignmentsMaxOralMark - @StudentsOralMark))
	SET @return = 'false';
    ELSE
    SET @return = 'true';

	-- Return the result of the function
	RETURN @return;

END
GO
/****** Object:  Table [dbo].[AssignmentsPerCoursePerStudent]    Script Date: 18-Nov-19 5:16:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AssignmentsPerCoursePerStudent](
	[StudentId] [int] NOT NULL,
	[CourseId] [int] NOT NULL,
	[AssignmentId] [int] NOT NULL,
	[StudentsOralMark] [float] NOT NULL,
	[StudentsTotalMark] [float] NOT NULL,
 CONSTRAINT [PK_AssignmentsPerCoursePerStudent] PRIMARY KEY CLUSTERED 
(
	[StudentId] ASC,
	[AssignmentId] ASC,
	[CourseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Students]    Script Date: 18-Nov-19 5:16:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Students](
	[StudentId] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](20) NOT NULL,
	[LastName] [nvarchar](30) NOT NULL,
	[DateOfBirth] [date] NOT NULL,
	[TuitionFees] [float] NOT NULL,
 CONSTRAINT [PK_Students] PRIMARY KEY CLUSTERED 
(
	[StudentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Courses]    Script Date: 18-Nov-19 5:16:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Courses](
	[CourseId] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](30) NOT NULL,
	[Stream] [nvarchar](5) NOT NULL,
	[Type] [nvarchar](10) NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NOT NULL,
 CONSTRAINT [PK_Courses] PRIMARY KEY CLUSTERED 
(
	[CourseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Assignments]    Script Date: 18-Nov-19 5:16:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Assignments](
	[AssignmentId] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](30) NOT NULL,
	[Description] [nvarchar](max) NOT NULL,
	[SubDateTime] [datetime] NOT NULL,
	[OralMark] [float] NOT NULL,
	[TotalMark] [float] NOT NULL,
 CONSTRAINT [PK_Assignments] PRIMARY KEY CLUSTERED 
(
	[AssignmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[AssignmentsPerCoursePerStudentView]    Script Date: 18-Nov-19 5:16:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AssignmentsPerCoursePerStudentView]
AS
SELECT dbo.AssignmentsPerCoursePerStudent.StudentId, dbo.Students.FirstName, dbo.Students.LastName, dbo.Students.DateOfBirth, dbo.Students.TuitionFees, dbo.AssignmentsPerCoursePerStudent.CourseId, dbo.Courses.Title, 
                  dbo.Courses.Stream, dbo.Courses.Type, dbo.Courses.StartDate, dbo.Courses.EndDate, dbo.AssignmentsPerCoursePerStudent.AssignmentId, dbo.Assignments.Title AS AssignmentTitle, dbo.Assignments.Description, 
                  dbo.Assignments.SubDateTime, dbo.AssignmentsPerCoursePerStudent.StudentsOralMark, dbo.AssignmentsPerCoursePerStudent.StudentsTotalMark
FROM     dbo.Assignments INNER JOIN
                  dbo.AssignmentsPerCoursePerStudent ON dbo.Assignments.AssignmentId = dbo.AssignmentsPerCoursePerStudent.AssignmentId INNER JOIN
                  dbo.Courses ON dbo.AssignmentsPerCoursePerStudent.CourseId = dbo.Courses.CourseId INNER JOIN
                  dbo.Students ON dbo.AssignmentsPerCoursePerStudent.StudentId = dbo.Students.StudentId
GO
/****** Object:  Table [dbo].[AssignmentsPerCourse]    Script Date: 18-Nov-19 5:16:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AssignmentsPerCourse](
	[CourseId] [int] NOT NULL,
	[AssignmentId] [int] NOT NULL,
 CONSTRAINT [PK_AssignmensPerCourse] PRIMARY KEY CLUSTERED 
(
	[CourseId] ASC,
	[AssignmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[AssignmentsPerCourseView]    Script Date: 18-Nov-19 5:16:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AssignmentsPerCourseView]
AS
SELECT dbo.AssignmentsPerCourse.CourseId, dbo.Courses.Title, dbo.Courses.Stream, dbo.Courses.Type, dbo.Courses.StartDate, dbo.Courses.EndDate, dbo.AssignmentsPerCourse.AssignmentId, dbo.Assignments.Title AS AssignmentTitle, 
                  dbo.Assignments.Description, dbo.Assignments.SubDateTime, dbo.Assignments.OralMark, dbo.Assignments.TotalMark
FROM     dbo.Assignments INNER JOIN
                  dbo.AssignmentsPerCourse ON dbo.Assignments.AssignmentId = dbo.AssignmentsPerCourse.AssignmentId INNER JOIN
                  dbo.Courses ON dbo.AssignmentsPerCourse.CourseId = dbo.Courses.CourseId
GO
/****** Object:  Table [dbo].[Trainers]    Script Date: 18-Nov-19 5:16:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Trainers](
	[TrainerId] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](20) NOT NULL,
	[LastName] [nvarchar](30) NOT NULL,
	[Subject] [nvarchar](150) NOT NULL,
 CONSTRAINT [PK_Trainers] PRIMARY KEY CLUSTERED 
(
	[TrainerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TrainersPerCourse]    Script Date: 18-Nov-19 5:16:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrainersPerCourse](
	[CourseId] [int] NOT NULL,
	[TrainerId] [int] NOT NULL,
 CONSTRAINT [PK_TrainersPerCourse] PRIMARY KEY CLUSTERED 
(
	[CourseId] ASC,
	[TrainerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[TrainersPerCourseView]    Script Date: 18-Nov-19 5:16:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TrainersPerCourseView]
AS
SELECT dbo.TrainersPerCourse.CourseId, dbo.Courses.Title, dbo.Courses.Stream, dbo.Courses.Type, dbo.Courses.StartDate, dbo.Courses.EndDate, dbo.TrainersPerCourse.TrainerId, dbo.Trainers.FirstName, dbo.Trainers.LastName, 
                  dbo.Trainers.Subject
FROM     dbo.Trainers INNER JOIN
                  dbo.TrainersPerCourse ON dbo.Trainers.TrainerId = dbo.TrainersPerCourse.TrainerId INNER JOIN
                  dbo.Courses ON dbo.TrainersPerCourse.CourseId = dbo.Courses.CourseId
GO
/****** Object:  Table [dbo].[StudentsPerCourse]    Script Date: 18-Nov-19 5:16:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StudentsPerCourse](
	[CourseId] [int] NOT NULL,
	[StudentId] [int] NOT NULL,
 CONSTRAINT [PK_StudentsPerCourse] PRIMARY KEY CLUSTERED 
(
	[CourseId] ASC,
	[StudentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[StudentsPerCourseView]    Script Date: 18-Nov-19 5:16:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[StudentsPerCourseView]
AS
SELECT dbo.StudentsPerCourse.CourseId, dbo.Courses.Title, dbo.Courses.Stream, dbo.Courses.Type, dbo.Courses.StartDate, dbo.Courses.EndDate, dbo.StudentsPerCourse.StudentId, dbo.Students.FirstName, dbo.Students.LastName, 
                  dbo.Students.DateOfBirth, dbo.Students.TuitionFees
FROM     dbo.Students INNER JOIN
                  dbo.StudentsPerCourse ON dbo.Students.StudentId = dbo.StudentsPerCourse.StudentId INNER JOIN
                  dbo.Courses ON dbo.StudentsPerCourse.CourseId = dbo.Courses.CourseId
GO
SET IDENTITY_INSERT [dbo].[Assignments] ON 

INSERT [dbo].[Assignments] ([AssignmentId], [Title], [Description], [SubDateTime], [OralMark], [TotalMark]) VALUES (1, N'C# Console App', N'In this assignment you need to create a console app in C#.', CAST(N'2019-12-12T23:59:59.000' AS DateTime), 25, 100)
INSERT [dbo].[Assignments] ([AssignmentId], [Title], [Description], [SubDateTime], [OralMark], [TotalMark]) VALUES (2, N'C# Console App 2', N'In this assignment you need to create another console app in C#.', CAST(N'2019-12-22T23:59:59.000' AS DateTime), 25, 100)
INSERT [dbo].[Assignments] ([AssignmentId], [Title], [Description], [SubDateTime], [OralMark], [TotalMark]) VALUES (3, N'Java Console App', N'In this assignment you need to create a console app in Java.', CAST(N'2020-03-10T23:59:59.000' AS DateTime), 25, 100)
INSERT [dbo].[Assignments] ([AssignmentId], [Title], [Description], [SubDateTime], [OralMark], [TotalMark]) VALUES (4, N'Java Console App 2', N'In this assignment you need to create another console app in Java.', CAST(N'2020-03-21T23:59:59.000' AS DateTime), 25, 100)
INSERT [dbo].[Assignments] ([AssignmentId], [Title], [Description], [SubDateTime], [OralMark], [TotalMark]) VALUES (5, N'Website', N'In this assignment you need to create a website using HTML, CSS and Javascript.', CAST(N'2020-01-13T23:59:59.000' AS DateTime), 25, 100)
INSERT [dbo].[Assignments] ([AssignmentId], [Title], [Description], [SubDateTime], [OralMark], [TotalMark]) VALUES (6, N'Website 2', N'In this assignment you need to create a website using HTML, CSS and Javascript.', CAST(N'2019-12-13T23:59:59.000' AS DateTime), 25, 100)
INSERT [dbo].[Assignments] ([AssignmentId], [Title], [Description], [SubDateTime], [OralMark], [TotalMark]) VALUES (7, N'C# Console App 3', N'In this assignment you need to create a console app in C#.', CAST(N'2020-01-08T23:59:59.000' AS DateTime), 25, 100)
INSERT [dbo].[Assignments] ([AssignmentId], [Title], [Description], [SubDateTime], [OralMark], [TotalMark]) VALUES (8, N'SQL Assignment', N'In this assignment you need to create a database and make queries to it.', CAST(N'2020-02-21T23:59:59.000' AS DateTime), 25, 100)
INSERT [dbo].[Assignments] ([AssignmentId], [Title], [Description], [SubDateTime], [OralMark], [TotalMark]) VALUES (10, N'C++ Console App', N'In this assignment you need to create another console app in C++.', CAST(N'2020-03-25T23:59:59.000' AS DateTime), 25, 100)
INSERT [dbo].[Assignments] ([AssignmentId], [Title], [Description], [SubDateTime], [OralMark], [TotalMark]) VALUES (11, N'C# Console App 4', N'In this assignment you need to create a console app using C# language.', CAST(N'2020-03-31T23:59:59.000' AS DateTime), 25, 100)
INSERT [dbo].[Assignments] ([AssignmentId], [Title], [Description], [SubDateTime], [OralMark], [TotalMark]) VALUES (12, N'SQL Assignment', N'In this assignment you need to create a database and make queries to it.', CAST(N'2020-04-30T23:59:59.000' AS DateTime), 25, 100)
INSERT [dbo].[Assignments] ([AssignmentId], [Title], [Description], [SubDateTime], [OralMark], [TotalMark]) VALUES (13, N'Java Console App 3', N'In this assignment you need to create another console app in Java.', CAST(N'2020-03-31T23:59:59.000' AS DateTime), 25, 100)
INSERT [dbo].[Assignments] ([AssignmentId], [Title], [Description], [SubDateTime], [OralMark], [TotalMark]) VALUES (14, N'Website 3', N'In this assignment you need to create a website using HTML, CSS and Javascript.', CAST(N'2020-04-30T23:59:59.000' AS DateTime), 25, 100)
SET IDENTITY_INSERT [dbo].[Assignments] OFF
INSERT [dbo].[AssignmentsPerCourse] ([CourseId], [AssignmentId]) VALUES (1, 1)
INSERT [dbo].[AssignmentsPerCourse] ([CourseId], [AssignmentId]) VALUES (1, 2)
INSERT [dbo].[AssignmentsPerCourse] ([CourseId], [AssignmentId]) VALUES (1, 5)
INSERT [dbo].[AssignmentsPerCourse] ([CourseId], [AssignmentId]) VALUES (2, 3)
INSERT [dbo].[AssignmentsPerCourse] ([CourseId], [AssignmentId]) VALUES (2, 4)
INSERT [dbo].[AssignmentsPerCourse] ([CourseId], [AssignmentId]) VALUES (2, 5)
INSERT [dbo].[AssignmentsPerCourse] ([CourseId], [AssignmentId]) VALUES (2, 6)
INSERT [dbo].[AssignmentsPerCourse] ([CourseId], [AssignmentId]) VALUES (3, 7)
INSERT [dbo].[AssignmentsPerCourse] ([CourseId], [AssignmentId]) VALUES (3, 8)
INSERT [dbo].[AssignmentsPerCourse] ([CourseId], [AssignmentId]) VALUES (4, 3)
INSERT [dbo].[AssignmentsPerCourse] ([CourseId], [AssignmentId]) VALUES (4, 5)
INSERT [dbo].[AssignmentsPerCourse] ([CourseId], [AssignmentId]) VALUES (7, 11)
INSERT [dbo].[AssignmentsPerCourse] ([CourseId], [AssignmentId]) VALUES (7, 12)
INSERT [dbo].[AssignmentsPerCourse] ([CourseId], [AssignmentId]) VALUES (8, 13)
INSERT [dbo].[AssignmentsPerCourse] ([CourseId], [AssignmentId]) VALUES (8, 14)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (1, 1, 1, 20, 95)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (1, 1, 2, 15, 80)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (1, 1, 5, 17, 73)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (2, 2, 3, 24, 99)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (2, 2, 4, 20, 91)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (2, 2, 5, 15, 85)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (2, 2, 6, 10, 80)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (3, 1, 1, 19, 94)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (3, 1, 2, 20, 86)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (3, 2, 3, 17, 90)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (3, 2, 4, 15, 87)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (3, 1, 5, 25, 98)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (3, 2, 5, 25, 98)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (3, 2, 6, 18, 93)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (4, 1, 1, 11, 86)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (4, 1, 2, 17, 90)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (4, 2, 3, 25, 95)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (4, 2, 4, 14, 89)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (4, 1, 5, 12, 85)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (4, 2, 5, 12, 85)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (4, 2, 6, 17, 87)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (5, 4, 3, 20, 92)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (5, 4, 5, 18, 90)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (6, 4, 3, 23, 87)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (6, 4, 5, 20, 90)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (7, 4, 3, 19, 85)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (7, 4, 5, 21, 96)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (8, 3, 7, 18, 82)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (8, 3, 8, 20, 94)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (9, 3, 7, 21, 96)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (9, 3, 8, 20, 92)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (10, 3, 7, 17, 85)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (10, 3, 8, 15, 80)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (11, 7, 11, 18, 85)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (11, 7, 12, 19, 88)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (12, 7, 11, 20, 95)
INSERT [dbo].[AssignmentsPerCoursePerStudent] ([StudentId], [CourseId], [AssignmentId], [StudentsOralMark], [StudentsTotalMark]) VALUES (12, 7, 12, 17, 85)
SET IDENTITY_INSERT [dbo].[Courses] ON 

INSERT [dbo].[Courses] ([CourseId], [Title], [Stream], [Type], [StartDate], [EndDate]) VALUES (6, N'Coding Bootcamp 10', N'C#', N'Full-Time', CAST(N'2020-02-01' AS Date), CAST(N'2020-05-15' AS Date))
INSERT [dbo].[Courses] ([CourseId], [Title], [Stream], [Type], [StartDate], [EndDate]) VALUES (7, N'Coding Bootcamp 10', N'C#', N'Part-Time', CAST(N'2020-02-01' AS Date), CAST(N'2020-07-31' AS Date))
INSERT [dbo].[Courses] ([CourseId], [Title], [Stream], [Type], [StartDate], [EndDate]) VALUES (8, N'Coding Bootcamp 10', N'Java', N'Full-Time', CAST(N'2020-02-01' AS Date), CAST(N'2020-05-15' AS Date))
INSERT [dbo].[Courses] ([CourseId], [Title], [Stream], [Type], [StartDate], [EndDate]) VALUES (9, N'Coding Bootcamp 10', N'Java', N'Part-Time', CAST(N'2020-02-01' AS Date), CAST(N'2020-07-31' AS Date))
INSERT [dbo].[Courses] ([CourseId], [Title], [Stream], [Type], [StartDate], [EndDate]) VALUES (1, N'Coding Bootcamp 9', N'C#', N'Full-Time', CAST(N'2019-10-14' AS Date), CAST(N'2020-01-22' AS Date))
INSERT [dbo].[Courses] ([CourseId], [Title], [Stream], [Type], [StartDate], [EndDate]) VALUES (3, N'Coding Bootcamp 9', N'C#', N'Part-Time', CAST(N'2019-10-14' AS Date), CAST(N'2020-04-22' AS Date))
INSERT [dbo].[Courses] ([CourseId], [Title], [Stream], [Type], [StartDate], [EndDate]) VALUES (4, N'Coding Bootcamp 9', N'Java', N'Full-Time', CAST(N'2019-10-14' AS Date), CAST(N'2020-01-22' AS Date))
INSERT [dbo].[Courses] ([CourseId], [Title], [Stream], [Type], [StartDate], [EndDate]) VALUES (2, N'Coding Bootcamp 9', N'Java', N'Part-Time', CAST(N'2019-10-14' AS Date), CAST(N'2020-04-22' AS Date))
SET IDENTITY_INSERT [dbo].[Courses] OFF
SET IDENTITY_INSERT [dbo].[Students] ON 

INSERT [dbo].[Students] ([StudentId], [FirstName], [LastName], [DateOfBirth], [TuitionFees]) VALUES (12, N'Babis', N'Iliopoulos', CAST(N'1985-12-13' AS Date), 2500)
INSERT [dbo].[Students] ([StudentId], [FirstName], [LastName], [DateOfBirth], [TuitionFees]) VALUES (13, N'Filippos', N'Karailanidis', CAST(N'1991-10-07' AS Date), 2500)
INSERT [dbo].[Students] ([StudentId], [FirstName], [LastName], [DateOfBirth], [TuitionFees]) VALUES (4, N'Giannis', N'Kotsianis', CAST(N'1995-02-20' AS Date), 4500)
INSERT [dbo].[Students] ([StudentId], [FirstName], [LastName], [DateOfBirth], [TuitionFees]) VALUES (11, N'Ilias', N'Papanikolaou', CAST(N'1991-02-22' AS Date), 2250)
INSERT [dbo].[Students] ([StudentId], [FirstName], [LastName], [DateOfBirth], [TuitionFees]) VALUES (8, N'Ioanna', N'Papadopoulou', CAST(N'1980-05-24' AS Date), 2500)
INSERT [dbo].[Students] ([StudentId], [FirstName], [LastName], [DateOfBirth], [TuitionFees]) VALUES (7, N'Konstantina', N'Paliou', CAST(N'1985-03-13' AS Date), 2500)
INSERT [dbo].[Students] ([StudentId], [FirstName], [LastName], [DateOfBirth], [TuitionFees]) VALUES (2, N'Kostas', N'Ioannou', CAST(N'1985-05-10' AS Date), 2250)
INSERT [dbo].[Students] ([StudentId], [FirstName], [LastName], [DateOfBirth], [TuitionFees]) VALUES (3, N'Maria', N'Oikonomou', CAST(N'1990-02-15' AS Date), 4500)
INSERT [dbo].[Students] ([StudentId], [FirstName], [LastName], [DateOfBirth], [TuitionFees]) VALUES (10, N'Marios', N'Papakonstantinou', CAST(N'1995-06-20' AS Date), 2500)
INSERT [dbo].[Students] ([StudentId], [FirstName], [LastName], [DateOfBirth], [TuitionFees]) VALUES (1, N'Markos', N'Markou', CAST(N'1992-01-24' AS Date), 2500)
INSERT [dbo].[Students] ([StudentId], [FirstName], [LastName], [DateOfBirth], [TuitionFees]) VALUES (5, N'Nikos', N'Nikolaou', CAST(N'1994-01-25' AS Date), 2500)
INSERT [dbo].[Students] ([StudentId], [FirstName], [LastName], [DateOfBirth], [TuitionFees]) VALUES (6, N'Pantelis', N'Koutlas', CAST(N'1980-08-10' AS Date), 2500)
INSERT [dbo].[Students] ([StudentId], [FirstName], [LastName], [DateOfBirth], [TuitionFees]) VALUES (9, N'Petros', N'Kostopoulos', CAST(N'1985-05-24' AS Date), 2500)
SET IDENTITY_INSERT [dbo].[Students] OFF
INSERT [dbo].[StudentsPerCourse] ([CourseId], [StudentId]) VALUES (1, 1)
INSERT [dbo].[StudentsPerCourse] ([CourseId], [StudentId]) VALUES (1, 3)
INSERT [dbo].[StudentsPerCourse] ([CourseId], [StudentId]) VALUES (1, 4)
INSERT [dbo].[StudentsPerCourse] ([CourseId], [StudentId]) VALUES (2, 2)
INSERT [dbo].[StudentsPerCourse] ([CourseId], [StudentId]) VALUES (2, 3)
INSERT [dbo].[StudentsPerCourse] ([CourseId], [StudentId]) VALUES (2, 4)
INSERT [dbo].[StudentsPerCourse] ([CourseId], [StudentId]) VALUES (3, 8)
INSERT [dbo].[StudentsPerCourse] ([CourseId], [StudentId]) VALUES (3, 9)
INSERT [dbo].[StudentsPerCourse] ([CourseId], [StudentId]) VALUES (3, 10)
INSERT [dbo].[StudentsPerCourse] ([CourseId], [StudentId]) VALUES (4, 5)
INSERT [dbo].[StudentsPerCourse] ([CourseId], [StudentId]) VALUES (4, 6)
INSERT [dbo].[StudentsPerCourse] ([CourseId], [StudentId]) VALUES (4, 7)
INSERT [dbo].[StudentsPerCourse] ([CourseId], [StudentId]) VALUES (6, 6)
INSERT [dbo].[StudentsPerCourse] ([CourseId], [StudentId]) VALUES (6, 7)
INSERT [dbo].[StudentsPerCourse] ([CourseId], [StudentId]) VALUES (7, 11)
INSERT [dbo].[StudentsPerCourse] ([CourseId], [StudentId]) VALUES (7, 12)
SET IDENTITY_INSERT [dbo].[Trainers] ON 

INSERT [dbo].[Trainers] ([TrainerId], [FirstName], [LastName], [Subject]) VALUES (3, N'Giannis', N'Petrou', N'HTML, CSS, Javascript')
INSERT [dbo].[Trainers] ([TrainerId], [FirstName], [LastName], [Subject]) VALUES (1, N'Ilias', N'Karabasis', N'C#')
INSERT [dbo].[Trainers] ([TrainerId], [FirstName], [LastName], [Subject]) VALUES (5, N'Ioanna', N'Konstantinou', N'SQL')
INSERT [dbo].[Trainers] ([TrainerId], [FirstName], [LastName], [Subject]) VALUES (4, N'Kostas', N'Petropoulos', N'C#')
INSERT [dbo].[Trainers] ([TrainerId], [FirstName], [LastName], [Subject]) VALUES (7, N'Maria', N'Papanikolaou', N'Java')
INSERT [dbo].[Trainers] ([TrainerId], [FirstName], [LastName], [Subject]) VALUES (6, N'Nikos', N'Nikolaou', N'HTML, CSS, Javascript')
INSERT [dbo].[Trainers] ([TrainerId], [FirstName], [LastName], [Subject]) VALUES (2, N'Petros', N'Papadopoulos', N'Java')
INSERT [dbo].[Trainers] ([TrainerId], [FirstName], [LastName], [Subject]) VALUES (9, N'Tasos', N'Patoulis', N'AngularJS')
SET IDENTITY_INSERT [dbo].[Trainers] OFF
INSERT [dbo].[TrainersPerCourse] ([CourseId], [TrainerId]) VALUES (1, 1)
INSERT [dbo].[TrainersPerCourse] ([CourseId], [TrainerId]) VALUES (1, 3)
INSERT [dbo].[TrainersPerCourse] ([CourseId], [TrainerId]) VALUES (2, 2)
INSERT [dbo].[TrainersPerCourse] ([CourseId], [TrainerId]) VALUES (2, 3)
INSERT [dbo].[TrainersPerCourse] ([CourseId], [TrainerId]) VALUES (3, 4)
INSERT [dbo].[TrainersPerCourse] ([CourseId], [TrainerId]) VALUES (3, 5)
INSERT [dbo].[TrainersPerCourse] ([CourseId], [TrainerId]) VALUES (4, 6)
INSERT [dbo].[TrainersPerCourse] ([CourseId], [TrainerId]) VALUES (4, 7)
INSERT [dbo].[TrainersPerCourse] ([CourseId], [TrainerId]) VALUES (6, 4)
INSERT [dbo].[TrainersPerCourse] ([CourseId], [TrainerId]) VALUES (6, 6)
INSERT [dbo].[TrainersPerCourse] ([CourseId], [TrainerId]) VALUES (8, 3)
INSERT [dbo].[TrainersPerCourse] ([CourseId], [TrainerId]) VALUES (8, 7)
SET ANSI_PADDING ON
GO
/****** Object:  Index [UniqueAssignment]    Script Date: 18-Nov-19 5:16:25 PM ******/
ALTER TABLE [dbo].[Assignments] ADD  CONSTRAINT [UniqueAssignment] UNIQUE NONCLUSTERED 
(
	[Title] ASC,
	[SubDateTime] ASC,
	[OralMark] ASC,
	[TotalMark] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UniqueCourse]    Script Date: 18-Nov-19 5:16:25 PM ******/
ALTER TABLE [dbo].[Courses] ADD  CONSTRAINT [UniqueCourse] UNIQUE NONCLUSTERED 
(
	[Title] ASC,
	[Stream] ASC,
	[Type] ASC,
	[StartDate] ASC,
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UniqueStudent]    Script Date: 18-Nov-19 5:16:25 PM ******/
ALTER TABLE [dbo].[Students] ADD  CONSTRAINT [UniqueStudent] UNIQUE NONCLUSTERED 
(
	[FirstName] ASC,
	[LastName] ASC,
	[DateOfBirth] ASC,
	[TuitionFees] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UniqueTrainer]    Script Date: 18-Nov-19 5:16:25 PM ******/
ALTER TABLE [dbo].[Trainers] ADD  CONSTRAINT [UniqueTrainer] UNIQUE NONCLUSTERED 
(
	[FirstName] ASC,
	[LastName] ASC,
	[Subject] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AssignmentsPerCourse]  WITH CHECK ADD  CONSTRAINT [FK_AssignmensPerCourse_Assignments] FOREIGN KEY([AssignmentId])
REFERENCES [dbo].[Assignments] ([AssignmentId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AssignmentsPerCourse] CHECK CONSTRAINT [FK_AssignmensPerCourse_Assignments]
GO
ALTER TABLE [dbo].[AssignmentsPerCourse]  WITH CHECK ADD  CONSTRAINT [FK_AssignmensPerCourse_Courses] FOREIGN KEY([CourseId])
REFERENCES [dbo].[Courses] ([CourseId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AssignmentsPerCourse] CHECK CONSTRAINT [FK_AssignmensPerCourse_Courses]
GO
ALTER TABLE [dbo].[AssignmentsPerCoursePerStudent]  WITH CHECK ADD  CONSTRAINT [FK_AssignmentsPerCoursePerStudent_Assignments] FOREIGN KEY([AssignmentId])
REFERENCES [dbo].[Assignments] ([AssignmentId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AssignmentsPerCoursePerStudent] CHECK CONSTRAINT [FK_AssignmentsPerCoursePerStudent_Assignments]
GO
ALTER TABLE [dbo].[AssignmentsPerCoursePerStudent]  WITH CHECK ADD  CONSTRAINT [FK_AssignmentsPerCoursePerStudent_Courses] FOREIGN KEY([CourseId])
REFERENCES [dbo].[Courses] ([CourseId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AssignmentsPerCoursePerStudent] CHECK CONSTRAINT [FK_AssignmentsPerCoursePerStudent_Courses]
GO
ALTER TABLE [dbo].[AssignmentsPerCoursePerStudent]  WITH CHECK ADD  CONSTRAINT [FK_AssignmentsPerCoursePerStudent_Students] FOREIGN KEY([StudentId])
REFERENCES [dbo].[Students] ([StudentId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AssignmentsPerCoursePerStudent] CHECK CONSTRAINT [FK_AssignmentsPerCoursePerStudent_Students]
GO
ALTER TABLE [dbo].[StudentsPerCourse]  WITH CHECK ADD  CONSTRAINT [FK_StudentsPerCourse_Courses] FOREIGN KEY([CourseId])
REFERENCES [dbo].[Courses] ([CourseId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[StudentsPerCourse] CHECK CONSTRAINT [FK_StudentsPerCourse_Courses]
GO
ALTER TABLE [dbo].[StudentsPerCourse]  WITH CHECK ADD  CONSTRAINT [FK_StudentsPerCourse_Students] FOREIGN KEY([StudentId])
REFERENCES [dbo].[Students] ([StudentId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[StudentsPerCourse] CHECK CONSTRAINT [FK_StudentsPerCourse_Students]
GO
ALTER TABLE [dbo].[TrainersPerCourse]  WITH CHECK ADD  CONSTRAINT [FK_TrainersPerCourse_Courses] FOREIGN KEY([CourseId])
REFERENCES [dbo].[Courses] ([CourseId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TrainersPerCourse] CHECK CONSTRAINT [FK_TrainersPerCourse_Courses]
GO
ALTER TABLE [dbo].[TrainersPerCourse]  WITH CHECK ADD  CONSTRAINT [FK_TrainersPerCourse_Trainers] FOREIGN KEY([TrainerId])
REFERENCES [dbo].[Trainers] ([TrainerId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TrainersPerCourse] CHECK CONSTRAINT [FK_TrainersPerCourse_Trainers]
GO
ALTER TABLE [dbo].[Assignments]  WITH CHECK ADD  CONSTRAINT [CK_Assignments] CHECK  (([Title]<>''))
GO
ALTER TABLE [dbo].[Assignments] CHECK CONSTRAINT [CK_Assignments]
GO
ALTER TABLE [dbo].[Assignments]  WITH CHECK ADD  CONSTRAINT [CK_Assignments_1] CHECK  (([Description]<>''))
GO
ALTER TABLE [dbo].[Assignments] CHECK CONSTRAINT [CK_Assignments_1]
GO
ALTER TABLE [dbo].[Assignments]  WITH CHECK ADD  CONSTRAINT [CK_Assignments_2] CHECK  (([OralMark]>=(0)))
GO
ALTER TABLE [dbo].[Assignments] CHECK CONSTRAINT [CK_Assignments_2]
GO
ALTER TABLE [dbo].[Assignments]  WITH CHECK ADD  CONSTRAINT [CK_Assignments_3] CHECK  (([TotalMark]>=(0)))
GO
ALTER TABLE [dbo].[Assignments] CHECK CONSTRAINT [CK_Assignments_3]
GO
ALTER TABLE [dbo].[AssignmentsPerCoursePerStudent]  WITH CHECK ADD  CONSTRAINT [CK_AssignmentsPerCoursePerStudent] CHECK  (([StudentsOralMark]>=(0)))
GO
ALTER TABLE [dbo].[AssignmentsPerCoursePerStudent] CHECK CONSTRAINT [CK_AssignmentsPerCoursePerStudent]
GO
ALTER TABLE [dbo].[AssignmentsPerCoursePerStudent]  WITH CHECK ADD  CONSTRAINT [CK_AssignmentsPerCoursePerStudent_1] CHECK  (([StudentsTotalMark]>=(0)))
GO
ALTER TABLE [dbo].[AssignmentsPerCoursePerStudent] CHECK CONSTRAINT [CK_AssignmentsPerCoursePerStudent_1]
GO
ALTER TABLE [dbo].[AssignmentsPerCoursePerStudent]  WITH CHECK ADD  CONSTRAINT [CK_AssignmentsPerCoursePerStudent_2] CHECK  (([dbo].[IsValidStudentsOralMark]([StudentsOralMark],[AssignmentId])='true'))
GO
ALTER TABLE [dbo].[AssignmentsPerCoursePerStudent] CHECK CONSTRAINT [CK_AssignmentsPerCoursePerStudent_2]
GO
ALTER TABLE [dbo].[AssignmentsPerCoursePerStudent]  WITH CHECK ADD  CONSTRAINT [CK_AssignmentsPerCoursePerStudent_3] CHECK  (([dbo].[IsValidStudentsTotalMark]([StudentsTotalMark],[StudentsOralMark],[AssignmentId])='true'))
GO
ALTER TABLE [dbo].[AssignmentsPerCoursePerStudent] CHECK CONSTRAINT [CK_AssignmentsPerCoursePerStudent_3]
GO
ALTER TABLE [dbo].[AssignmentsPerCoursePerStudent]  WITH CHECK ADD  CONSTRAINT [CK_AssignmentsPerCoursePerStudent_4] CHECK  (([dbo].[IsValidAssignmentPerCoursePerStudent]([AssignmentId],[CourseId],[StudentId])='true'))
GO
ALTER TABLE [dbo].[AssignmentsPerCoursePerStudent] CHECK CONSTRAINT [CK_AssignmentsPerCoursePerStudent_4]
GO
ALTER TABLE [dbo].[Courses]  WITH CHECK ADD  CONSTRAINT [CK_Courses] CHECK  (([Title]<>''))
GO
ALTER TABLE [dbo].[Courses] CHECK CONSTRAINT [CK_Courses]
GO
ALTER TABLE [dbo].[Courses]  WITH CHECK ADD  CONSTRAINT [CK_Courses_1] CHECK  (([Stream]<>''))
GO
ALTER TABLE [dbo].[Courses] CHECK CONSTRAINT [CK_Courses_1]
GO
ALTER TABLE [dbo].[Courses]  WITH CHECK ADD  CONSTRAINT [CK_Courses_2] CHECK  (([Type]<>''))
GO
ALTER TABLE [dbo].[Courses] CHECK CONSTRAINT [CK_Courses_2]
GO
ALTER TABLE [dbo].[Courses]  WITH CHECK ADD  CONSTRAINT [CK_Courses_3] CHECK  (([EndDate]>[StartDate]))
GO
ALTER TABLE [dbo].[Courses] CHECK CONSTRAINT [CK_Courses_3]
GO
ALTER TABLE [dbo].[Courses]  WITH CHECK ADD  CONSTRAINT [CK_Courses_4] CHECK  (([Stream]='C#' OR [Stream]='Java'))
GO
ALTER TABLE [dbo].[Courses] CHECK CONSTRAINT [CK_Courses_4]
GO
ALTER TABLE [dbo].[Courses]  WITH CHECK ADD  CONSTRAINT [CK_Courses_5] CHECK  (([Type]='Full-Time' OR [Type]='Part-Time'))
GO
ALTER TABLE [dbo].[Courses] CHECK CONSTRAINT [CK_Courses_5]
GO
ALTER TABLE [dbo].[Students]  WITH CHECK ADD  CONSTRAINT [CK_Students] CHECK  ((NOT [FirstName] like '%[^A-Za-z]%'))
GO
ALTER TABLE [dbo].[Students] CHECK CONSTRAINT [CK_Students]
GO
ALTER TABLE [dbo].[Students]  WITH CHECK ADD  CONSTRAINT [CK_Students_1] CHECK  ((NOT [LastName] like '%[^A-Za-z]%'))
GO
ALTER TABLE [dbo].[Students] CHECK CONSTRAINT [CK_Students_1]
GO
ALTER TABLE [dbo].[Students]  WITH CHECK ADD  CONSTRAINT [CK_Students_2] CHECK  (([FirstName]<>''))
GO
ALTER TABLE [dbo].[Students] CHECK CONSTRAINT [CK_Students_2]
GO
ALTER TABLE [dbo].[Students]  WITH CHECK ADD  CONSTRAINT [CK_Students_3] CHECK  (([LastName]<>''))
GO
ALTER TABLE [dbo].[Students] CHECK CONSTRAINT [CK_Students_3]
GO
ALTER TABLE [dbo].[Students]  WITH CHECK ADD  CONSTRAINT [CK_Students_4] CHECK  (([DateOfBirth]<getdate()))
GO
ALTER TABLE [dbo].[Students] CHECK CONSTRAINT [CK_Students_4]
GO
ALTER TABLE [dbo].[Students]  WITH CHECK ADD  CONSTRAINT [CK_Students_5] CHECK  (([TuitionFees]>=(0)))
GO
ALTER TABLE [dbo].[Students] CHECK CONSTRAINT [CK_Students_5]
GO
ALTER TABLE [dbo].[Trainers]  WITH CHECK ADD  CONSTRAINT [CK_Trainers] CHECK  ((NOT [FirstName] like '%[^A-Za-z]%'))
GO
ALTER TABLE [dbo].[Trainers] CHECK CONSTRAINT [CK_Trainers]
GO
ALTER TABLE [dbo].[Trainers]  WITH CHECK ADD  CONSTRAINT [CK_Trainers_1] CHECK  ((NOT [LastName] like '%[^A-Za-z]%'))
GO
ALTER TABLE [dbo].[Trainers] CHECK CONSTRAINT [CK_Trainers_1]
GO
ALTER TABLE [dbo].[Trainers]  WITH CHECK ADD  CONSTRAINT [CK_Trainers_2] CHECK  (([FirstName]<>''))
GO
ALTER TABLE [dbo].[Trainers] CHECK CONSTRAINT [CK_Trainers_2]
GO
ALTER TABLE [dbo].[Trainers]  WITH CHECK ADD  CONSTRAINT [CK_Trainers_3] CHECK  (([LastName]<>''))
GO
ALTER TABLE [dbo].[Trainers] CHECK CONSTRAINT [CK_Trainers_3]
GO
/****** Object:  Trigger [dbo].[CapitalizeStudentNamesFirstLetterAfterInsertOrUpdate]    Script Date: 18-Nov-19 5:16:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[CapitalizeStudentNamesFirstLetterAfterInsertOrUpdate] ON [dbo].[Students]
AFTER INSERT, UPDATE AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @StudentId INT;
	DECLARE @FirstName NVARCHAR(50);
	DECLARE @LastName NVARCHAR(50);

	DECLARE myCursor CURSOR FOR
        SELECT StudentId, FirstName, LastName FROM inserted;
    OPEN myCursor; /*Open cursor for reading*/

	DECLARE @FirstLetter NVARCHAR(1);
	DECLARE @NewFirstName NVARCHAR(50);
	DECLARE @NewLastName NVARCHAR(50);

	FETCH NEXT FROM myCursor INTO @StudentId, @FirstName, @LastName;
	WHILE @@FETCH_STATUS = 0 
    BEGIN	
		SET @FirstLetter = SUBSTRING(@FirstName, 1, 1);
		SET @NewFirstName = UPPER(@FirstLetter) + LOWER(SUBSTRING(@FirstName, 2, LEN(@FirstName) - 1));
		SET @FirstLetter = SUBSTRING(@LastName, 1, 1);
		SET @NewLastName = UPPER(@FirstLetter) + LOWER(SUBSTRING(@LastName, 2, LEN(@LastName) - 1));
		UPDATE Students SET FirstName = @NewFirstName, LastName = @NewLastName WHERE StudentId = @StudentId;
		FETCH NEXT FROM myCursor INTO @StudentId, @FirstName, @LastName;
	END;
	CLOSE myCursor;
    DEALLOCATE myCursor;
END;
GO
ALTER TABLE [dbo].[Students] ENABLE TRIGGER [CapitalizeStudentNamesFirstLetterAfterInsertOrUpdate]
GO
/****** Object:  Trigger [dbo].[CapitalizeTrainerNamesFirstLetterAfterInsertOrUpdate]    Script Date: 18-Nov-19 5:16:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[CapitalizeTrainerNamesFirstLetterAfterInsertOrUpdate] ON [dbo].[Trainers]
AFTER INSERT, UPDATE AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @TrainerId INT;
	DECLARE @FirstName NVARCHAR(50);
	DECLARE @LastName NVARCHAR(50);

	DECLARE myCursor CURSOR FOR
        SELECT TrainerId, FirstName, LastName FROM inserted;
    OPEN myCursor; /*Open cursor for reading*/

	DECLARE @FirstLetter NVARCHAR(1);
	DECLARE @NewFirstName NVARCHAR(50);
	DECLARE @NewLastName NVARCHAR(50);

	FETCH NEXT FROM myCursor INTO @TrainerId, @FirstName, @LastName;
	WHILE @@FETCH_STATUS = 0 
    BEGIN	
		SET @FirstLetter = SUBSTRING(@FirstName, 1, 1);
		SET @NewFirstName = UPPER(@FirstLetter) + LOWER(SUBSTRING(@FirstName, 2, LEN(@FirstName) - 1));
		SET @FirstLetter = SUBSTRING(@LastName, 1, 1);
		SET @NewLastName = UPPER(@FirstLetter) + LOWER(SUBSTRING(@LastName, 2, LEN(@LastName) - 1));
		UPDATE Trainers SET FirstName = @NewFirstName, LastName = @NewLastName WHERE TrainerId = @TrainerId;
		FETCH NEXT FROM myCursor INTO @TrainerId, @FirstName, @LastName;
	END;
	CLOSE myCursor;
    DEALLOCATE myCursor;
END;
GO
ALTER TABLE [dbo].[Trainers] ENABLE TRIGGER [CapitalizeTrainerNamesFirstLetterAfterInsertOrUpdate]
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
         Begin Table = "Assignments"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AssignmentsPerCoursePerStudent"
            Begin Extent = 
               Top = 7
               Left = 290
               Bottom = 170
               Right = 509
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Courses"
            Begin Extent = 
               Top = 7
               Left = 557
               Bottom = 170
               Right = 751
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Students"
            Begin Extent = 
               Top = 7
               Left = 799
               Bottom = 170
               Right = 993
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
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 2832
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AssignmentsPerCoursePerStudentView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AssignmentsPerCoursePerStudentView'
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
         Begin Table = "Assignments"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AssignmentsPerCourse"
            Begin Extent = 
               Top = 7
               Left = 290
               Bottom = 126
               Right = 484
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Courses"
            Begin Extent = 
               Top = 7
               Left = 532
               Bottom = 170
               Right = 726
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
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AssignmentsPerCourseView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AssignmentsPerCourseView'
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
         Begin Table = "Students"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "StudentsPerCourse"
            Begin Extent = 
               Top = 7
               Left = 290
               Bottom = 126
               Right = 484
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Courses"
            Begin Extent = 
               Top = 7
               Left = 532
               Bottom = 170
               Right = 726
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
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'StudentsPerCourseView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'StudentsPerCourseView'
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
         Begin Table = "Trainers"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TrainersPerCourse"
            Begin Extent = 
               Top = 7
               Left = 290
               Bottom = 126
               Right = 484
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Courses"
            Begin Extent = 
               Top = 7
               Left = 532
               Bottom = 170
               Right = 726
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
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'TrainersPerCourseView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'TrainersPerCourseView'
GO
USE [master]
GO
ALTER DATABASE [PrivateSchool] SET  READ_WRITE 
GO
