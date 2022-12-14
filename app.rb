#encoding: utf-8
require 'rubygems' 			# Подключаем возможность использования гемов Руби
require 'sinatra'				# Подключаем гем Синатры
require 'sinatra/reloader' # Подключаем гем для обновления страницы без перезапуска синатры
require 'sqlite3'				# Подключаем SQL


		# Реализуем функцию опроса БД барберс на предмет присутствия
		# записей в ней. Возвращает булевое значения true\false
def is_barber_exists? db, name 
		db.execute('select * from barbers where name=?', [name]).length > 0
end

		# Добавление записей в таблицу barbers
def seed_db db, barbers
				# Перебираем все значения в БД
		barbers.each do |barber|
						# Ищем среди перебираемых не существует ли искомый и если
						# нет, то добавляем его в БД
			if !is_barber_exists? db, barber
				db.execute 'insert into Barbers (name) values (?)', [barber]

			end
		end
end

def get_db
  		db = SQLite3::Database.new 'Barbershop.sqlite'
  		db.results_as_hash = true
  		return db
end

		# Метод before позволяет вызывать нужные данные на каждой странице при каждой 
		# загрузке. Подобным образом проверяется авторизация пользователя на каждой 
		# открытой странице сайта (когда горит иконка авторизованного пользователя в 
		# правом верхнем углу)
before do
	db = get_db
	@barbers = db.execute 'select * from barbers'
end


# Инициализация БД
##############################
configure do 

	# Подключение к БД. Если файл есть - будет открыт, если нет - будет создан.
	db = get_db 

			# Создаем таблицу при открытии БД
	db.execute 'create table if not exists "users"
		( 
		  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
		  "username" TEXT,
		  "phone" TEXT,
		  "datestamp" TEXT,
		  "barber" TEXT,
		  "color" TEXT
		)'
			# создание таблицы парикмахеров barbers
	db.execute 'create table if not exists "barbers"
		( 
		  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
		  "name" TEXT
		)'

			# вызываем функцию seed_db для заполнения списка выбора мастеров
	seed_db db, [ 'Jessie Pinkman', 'Walter White', 'Gus Fring', 'Mike Rappoport' ]
end

######################################
get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>!!!"			
end

get '/about' do
	@error = "Something wrong!!!"

	erb "О нас"  # 	метод обработчика при котором используем yield функцию из layout.erb (~43 line)
end

get '/visit' do 
	erb :visit   # метод обработчика при котором используем прямое указание на новую страницу с текстом на ней
end

post '/visit' do
	@username = params[:username]
	@phone    = params[:phone]
	@datetime = params[:datetime]
	@barber   = params[:barber]
	@color	 = params[:color]

	# хэш для обработки ошибок заполнения полей формы
	hh = {:username =>'Введите имя',
			:phone => 'Укажите телефон',
			:datetime => 'Введите дату и время'}
=begin Можно далее использовать проверку по пошаговому варианту или по-новому ниже
	# для каждой пары ключ-значение
	hh.each do |key, value|

		# если параметр пуст
		if params[key] == ''

				# переменной error присвоить value из хэша hh
				# (а value из хэша hh это сообщение об ошибке)
				# т.е. переменной error присвоить сообщение об ошибке
				@error = hh[key]

				# в конце вернуть представление Visit

				return erb :visit
		end
	end

	По старому, а можно по новому коду ниже
=end

	# более универсальный способ
	@error = hh.select {|key,_| params[key] == ""}.values.join(", ")
	# но тоже есть свой минус - его надо повторять для каждой страницы где он нужен
	
	if @error !=''
		return erb :visit
	end

	# Сохраняем в БД инпут пользователя SQL запросом.
	# !!! колонка времени названа datestamp по причине того, что
	# datetime является зарезервированным словом в SQL, что могло
	# привести к ошибкам в дальнейшем в работе с БД.
	
	db = SQLite3::Database.new 'Barbershop.sqlite'
	db.execute 'INSERT INTO 
		users
		(
			username,
			phone,
			datestamp,
			barber,
			color
		) 
		values ( ?, ?, ?, ?, ?)' , [@username, @phone, @datetime, @barber, @color]
	
	erb "<h2>Спасибо, вы записались!</h2>"

end

get '/showusers' do
	db = get_db

		# собираем в переменную результат выборки из БД
	@results = db.execute 'select * from Users order by id desc'


	erb :showusers
=begin	@users=[]
	db = SQLite3::Database.new 'Barbershop.sqlite'
	db.execute 'select * from users order by id desc' do |row|
		
		@users << row[1]
		print row[1]
		puts "==========="
		
	end

	erb "Users next #{@users}"
=end	
	# erb "OK, username is #{@username}, #{@phone}, #{@datetime}, #{@barber}, #{@color}"

   # erb  "Hello World"

end