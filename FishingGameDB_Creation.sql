create database FishingGameDB
go

use FishingGameDB
go


-- Tables

-- tbl_Fishermans
create table tbl_Fishermans (
	FishermanID int Identity (1,1) Primary Key,
	[Name] nvarchar(40)  not null,
	Rating int default 0
)

insert into tbl_Fishermans (Name) values ('Avi')
insert into tbl_Fishermans (Name) values ('Moshe')
insert into tbl_Fishermans (Name) values ('Shir')





-- tbl_Countries
create table tbl_Countries (
	CountryID integer Identity (1,1) Primary Key,
	Country nvarchar(40) unique
)

insert into tbl_Countries values('France')
insert into tbl_Countries values('Germany')
insert into tbl_Countries values('Ireland')
insert into tbl_Countries values('Italy')
insert into tbl_Countries values('Mexico')
insert into tbl_Countries values('Norway')
insert into tbl_Countries values('Poland')
insert into tbl_Countries values('Portugal')
insert into tbl_Countries values('Spain')
insert into tbl_Countries values('Sweden')
insert into tbl_Countries values('Switzerland')
insert into tbl_Countries values('UK')
insert into tbl_Countries values('USA')
insert into tbl_Countries values('Venezuela')
insert into tbl_Countries values('Israel')



-- tbl_Genders
create table tbl_Genders (
	GenderID integer Identity (1,1) Primary Key,
	Gender nvarchar(10) unique not null
)

insert into tbl_Genders values('male')
insert into tbl_Genders values('female')


-- tbl_GameConfiguration
create table tbl_GameConfiguration (
	parameter nvarchar(20) not null,
	[value] nvarchar(10) not null
)

insert into tbl_GameConfiguration values ('num_of_sets', '10')
insert into tbl_GameConfiguration values ('left_win_border', '1')
insert into tbl_GameConfiguration values ('right_win_border', '60')

go

-- tbl_Users
create table tbl_Users (
	UserId int Identity (1,1) Primary Key,
	Username nvarchar(40) unique not null,
	[Password] nvarchar(40) not null,
	Firstname nvarchar(40) not null,
	Lastname nvarchar(40) not null,
	[Address] nvarchar(40),
	CountryID integer foreign key references tbl_Countries(CountryID),
	Email nvarchar(40) unique not null,
	GenderID integer foreign key references tbl_Genders(GenderID),
	BirthDate date,
	[Status] bit default 0
)

go

--  tbl_ScoreStatus
create table tbl_ScoreStatus (
	UserID integer unique NOT NULL Foreign key references tbl_Users(UserId),
	Poinits	integer default 1000,
	GainsCount integer default 0,
	LostsCount integer default 0
)

go

-- Custom Data Types
create type ct_FishLocation as table (
	FishNumber int unique,
	[Location] int default 0
)
go

-- Functions

-- fn_Rand
create view [dbo].[vv_getRandValue]
as
select rand() as [value]

go

Create function [dbo].[fn_Rand](@Lower int, @Upper int)
returns int
as
Begin
	DECLARE @Random INT;
	if @Upper > @Lower
		SELECT @Random = (1 + @Upper - @Lower) * (SELECT Value FROM vv_getRANDValue) + @Lower
	Else
		SELECT @Random = (1 + @Lower - @Upper) * (SELECT Value FROM vv_getRANDValue) + @Upper
	return @Random
end

go

-- fn_drawFish
create function fn_drawFish()
returns nvarchar(40) as
begin
	declare @pic_fish nvarchar(40) = ' ><> '

	return @pic_fish
end

go

-- fn_updateFishermanRating
create function fn_updateFishermanRating(@fisherman_id int)
returns int as
begin
	declare @current_rating int = (select rating from tbl_Fishermans where FishermanID = @fisherman_id)
	declare @new_rating int = @current_rating + 1

	return @new_rating
end

go

-- fn_ValidEmail

Create Function fn_ValidEmail(@Email varchar(40))
Returns bit as
Begin 

	Declare @bitRetVal Bit

	If (@Email <> '' and @Email not like '_%@__%.__%') 
		Set @bitRetVal = 1 -- Invalid 
	Else
		Set @bitRetVal = 0 -- Valid 
	 
	Return @bitRetVal
End

go

-- fn_checkAge

Create Function fn_checkAge (@birthdate  date)
Returns int
Begin

	declare @years int
	declare @months int
	declare @days int
	declare @revstatus int

	Set @years = DATEDIFF(yy, @birthdate, getdate()) 
	Set @months = DATEDIFF(mm, @birthdate, getdate()) % 12 


	if MONTH(@birthdate) > MONTH(getdate())
		Set @years = @years - 1 
    Else
	Begin
		if MONTH (@birthdate) = MONTH(getdate())
			if DAY(@birthdate) > DAY(getdate())
			Begin
				Set @years = @years - 1
				Set @months = @months - 1
			End
	End

	if (@years < 13)
		set @revstatus = 1
	else
		set @revstatus = 0

	return @revstatus
End

go

-- Procedures

-- sp_SelectFishermanID
create procedure sp_SelectFishermanID
as
	select 'Please select FishermanID from following table:' as [Message], * from
	(select * from tbl_Fishermans) t

go

-- sp_RunOneSet
create procedure sp_RunOneSet
	@t_fl [dbo].[ct_FishLocation] readonly,
	@set_type int
as
-- Set type 0 - general, Set type 1 - finally 
begin
	declare @set_result int = 0
	declare @pic_fish nvarchar(40)
	declare @pic_fish_with_location nvarchar(300)
	declare @fish_location int
	declare @catched_fish_number int
	declare @i int = 1
	
	declare @fishermans_count int = (select count(*) from tbl_Fishermans)
	
	set @catched_fish_number = dbo.fn_Rand(1, @fishermans_count)
	
	while (@i <= @fishermans_count)
	begin
		set @pic_fish_with_location = ''
		set @fish_location = (select [Location] from @t_fl where FishNumber = @i)
		set @pic_fish = (select dbo.fn_drawFish())
		if (@set_type = 0)
			set @pic_fish_with_location = space(@fish_location) + @pic_fish + CHAR(10)
		else
		begin
			if (@catched_fish_number = @i)
			begin
				set @set_result = @catched_fish_number
				set @pic_fish_with_location = 
					space(@fish_location) + '-------' + CHAR(10) +
					space(@fish_location) + '|' + @pic_fish + '|' + CHAR(10) +
					space(@fish_location) + '-------'
			end
			else
				set @pic_fish_with_location = space(@fish_location) + @pic_fish + CHAR(10)
		end
		print @pic_fish_with_location
		set @i = @i + 1
	end
	print '--------------------------------------------------------------------'

	return @set_result
end

go

-- sp_RunAllSets
create procedure sp_RunAllSets
as
begin
	declare @i int = 1
	declare @j int = 1
	declare @new_fish_location int
	declare @fisherman_winner_id int = 0
	declare @fisherman_winner_name nvarchar(40)
	declare @fisherman_winner_rating int
	declare @sets_count int = 
		convert(int, 
			(select [value] from tbl_GameConfiguration where parameter = 'num_of_sets'))

	declare @left_win_border int = convert(int, 
			(select [value] from tbl_GameConfiguration where parameter = 'left_win_border')
		)

	declare @right_win_border int = convert(int, 
			(select [value] from tbl_GameConfiguration where parameter = 'right_win_border')
		)

	declare @fishermans_count int = (select count(*) from tbl_Fishermans)
	declare @step_size int = (@right_win_border - @left_win_border) / @sets_count
	declare @step_jump int

	declare @t_fishlocation as [dbo].[ct_FishLocation]

	while (@j <= @fishermans_count)
	begin
		insert into @t_fishlocation values(@j, 0)
		set @j = @j + 1
	end
	
	print '--------------------------------------------------------------------'
	while (@i <= @sets_count)
	begin
		print 'Round Number ' + convert(nvarchar(5), @i)
		set @j = 1
		while ( @j <= (select count(*) from @t_fishlocation) )
		begin
			set @step_jump = dbo.fn_Rand(1, @step_size) + 2
			set @new_fish_location = ((select [Location] from @t_fishlocation where FishNumber = @j) + @step_jump)
			update @t_fishlocation set [Location] = @new_fish_location where FishNumber = @j
			set @j = @j + 1
		end
		if (@i = @sets_count)
		begin
			print 'This is final round' 
			exec @fisherman_winner_id = sp_RunOneSet @set_type = 1, @t_fl = @t_fishlocation
			set @fisherman_winner_name = (select [name] from  tbl_Fishermans where FishermanID = @fisherman_winner_id)
			print 'The fisherman winner is: ' + @fisherman_winner_name
			set @fisherman_winner_rating = (select dbo.fn_updateFishermanRating(@fisherman_winner_id))
			update tbl_Fishermans set rating = @fisherman_winner_rating where FishermanID = @fisherman_winner_id
			print 'The new rating of ' + @fisherman_winner_name + ' is ' + convert(varchar, @fisherman_winner_rating)
			print ''
		end
		else
			exec @fisherman_winner_id = sp_RunOneSet @set_type = 0, @t_fl = @t_fishlocation
		set @i = @i + 1 
	end

	return @fisherman_winner_id 
end

go

-- sp_RunFishermanGame
create procedure sp_RunFishermanGame
	@user_id int,
	@fisherman_id int
as 
begin
	SET NOCOUNT ON
		
	declare @fisherman_winner_id int
	declare @current_points int
	declare @login_status bit

	set @current_points = (select [Poinits] from tbl_ScoreStatus where UserID = @user_id)
	if (@current_points <= 0)
	begin
		throw 50001, 'You dont have enougth points for play this game, Please, contact with game administrator for fixing this issue', 1
	end

	set @login_status = (select [Status] from tbl_Users where UserID = @user_id)
	if (@login_status = 0)
		throw 50007, 'Please, make login before playing the game', 1

	exec @fisherman_winner_id = sp_RunAllSets
	if (@fisherman_winner_id = @fisherman_id)
	begin
		print 'Congratulation !!! You win 100 points!!!'
		update tbl_ScoreStatus set [GainsCount] = (
			(select [GainsCount] from tbl_ScoreStatus where UserID = @user_id) + 1)
		where UserID = @user_id

		update tbl_ScoreStatus set [Poinits] = (
			(select [Poinits] from tbl_ScoreStatus where UserID = @user_id) + 100)
		where UserID = @user_id
	end
	else
	begin
		print 'You lost. Unfortunately, you lost 100 points.' 
		update tbl_ScoreStatus set [LostsCount] = (
			(select [LostsCount] from tbl_ScoreStatus where UserID = @user_id) + 1)
		where UserID = @user_id

		update tbl_ScoreStatus set [Poinits] = (
			(select [Poinits] from tbl_ScoreStatus where UserID = @user_id) - 100)
		where UserID = @user_id
	end

	set @current_points = (select [Poinits] from tbl_ScoreStatus where UserID = @user_id)
	print 'You have ' + convert(varchar, @current_points) + ' points'
end

go

-- Check Username

create procedure sp_If_username_exist
  @user nvarchar(40)
As
Begin
	declare @status bit

	If ( (select count(*) from tbl_Users where Username = @user )> 0 )
		set @status = 1 
	Else 
		set @status = 0 

	return @status
End

go

-- sp_checkpassword
create procedure sp_checkpassword 
	@pass varchar(40),
	@user nvarchar(40)
as 
begin
	declare @retval int 
	
	begin
	if (len(@pass)< 7 or patindex('%[0-9]%', @pass ) <=0 or patindex('%[a-z]%' collate Latin1_General_Bin, @pass) <= 0 or PATINDEX('%[A-Z]%' collate Latin1_General_Bin, @pass ) <= 0)
		set @retval = 1
	else
		set @retval = 0
	
	end

	if (@pass = @user)
	begin
		print 'The password can not be same as username'
		set @retval = 1
	end

	if (@pass = 'password')
	begin
		print 'The password can not be word "password"'
		set @retval = 1
	end

	return @retval
end

go

-- Registration 

Create procedure sp_UserAdd
	@Username nvarchar(40),
	@Password nvarchar(40),
	@Firstname nvarchar(40),
	@Lastname nvarchar(40),
	@Adress nvarchar(40),
	@Country nvarchar(40),
	@Email nvarchar(40),
	@Gender nvarchar(10),
	@Birthdate nvarchar(30)
as 
begin
	declare @user_prefix int
	declare @new_username nvarchar(40)
	declare @if_user_exists bit
	declare @password_status int
	declare @email_status bit
	declare @age_status bit
	declare @CountryID int
	declare @GenderID int

	set @Birthdate = CONVERT(date, @Birthdate)
	set @CountryID = (select CountryID from tbl_Countries where Country = @Country)
	set @GenderID = (select GenderID from tbl_Genders where Gender = @Gender)

	-- Check username
	exec @if_user_exists = sp_If_username_exist @user = @Username
	set @new_username = @username
	while (@if_user_exists = 1)
	begin
		print 'The user ' + @Username + ' already exists'
		set @user_prefix = dbo.fn_Rand(1, 999)
		set @new_username = @Username + convert(varchar, @user_prefix)
		print 'The new username is ' + @new_username
		exec @if_user_exists  =  sp_If_username_exist @user = @new_username
	end
	set @username = @new_username


	-- Check Password

	exec @password_status = sp_checkpassword @pass = @Password, @user = @Username
	if (@password_status = 1)
	begin
		throw 50002, 'The password is not correct !!! Please type new password', 1
	end

	--Check Email 

	set @email_status = (select dbo.fn_ValidEmail(@Email))
	if (@email_status = 1)
	begin
		throw 50003, 'The email is not valid !!! Please type new email', 1
	end


	--Check Minimum_Age

	set @age_status = (select dbo.fn_checkAge(@Birthdate))
	if (@age_status = 1)
	begin
		throw 50004, 'You are too young to play!! Try again in a few years', 1
	end


	Insert into tbl_Users ( Username, Password, Firstname, Lastname, [Address], CountryID, Email, GenderID, BirthDate )
	Values (@Username, @Password, @Firstname, @Lastname, @Adress, @CountryID, @Email, @GenderID, @Birthdate )

	insert into tbl_ScoreStatus (UserID) select UserId from tbl_Users where Username = @Username
	
end

go

-- sp_Login
create procedure sp_Login 
	@username nvarchar(40)
as
begin
	declare @login_status bit

	set @login_status = (select [Status] from tbl_Users where Username = @username) 
	if (@login_status = 1)
		throw 50005, 'The user already login. Please, make logout begore login', 1
	else
	begin
		update tbl_Users set [Status] = 1 where Username = @username
		print 'The user ' + @username + ' made login succefully'
	end
end

go

-- sp_Logout
create procedure sp_Logout
	@username nvarchar(40)
as
begin
	declare @login_status bit

	set @login_status = (select [Status] from tbl_Users where Username = @username) 
	if (@login_status = 1)
	begin
		update tbl_Users set [Status] = 0 where Username = @username
		print 'The user ' + @username + ' made logout succefully'
	end
	else
		throw 50006, 'The user already logged out.', 1
end