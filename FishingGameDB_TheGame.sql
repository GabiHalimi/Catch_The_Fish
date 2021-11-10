use FishingGameDB
go

exec sp_UserAdd 
	@Username = 'MCOHEN',
	@Password = 'Qwer1234',
	@Firstname = 'Moshe',
	@Lastname = 'Cohen',
	@Adress = 'Tel Aviv, str. Moshe Dyan 15',
	@Country = 'Israel',
	@Email = 'mcohen@gmail.com',
	@Gender = 'male',
	@Birthdate = '12/01/1992'

exec sp_Login @username = 'MCOHEN'
exec [dbo].[sp_SelectFishermanID]
exec sp_RunFishermanGame @user_id = 1, @fisherman_id = 2

declare @i int = 1
while (@i < 20)
begin
	exec sp_RunFishermanGame @user_id = 1, @fisherman_id = 2
	set @i = @i + 1
end

exec sp_Logout @username = 'MCOHEN'