#encoding: utf-8
require 'rubygems' 			# Подключаем возможность использования гемов Руби
require 'sinatra'				# Подключаем гем Синатры
require 'sinatra/reloader' # Подключаем гем для обновления страницы без перезапуска синатры
require 'sqlite3'				# Подключаем SQL

# Инициализация БД
configure do 

	# Подключение к БД. Если файл есть - будет открыт, если нет - будет создан.
	@db = SQLite3::Database.new 'Barbershop.sqlite' 

	# Создаем таблицу
	@db.execute 'create table if not exists "users"
	( 
	  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
	  "username" TEXT,
	  "datestamp" TEXT,
	  "barber" TEXT,
	  "color" TEXT
	)'
end


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

	erb "OK, username is #{@username}, #{@phone}, #{@datetime}, #{@barber}, #{@color}"

end