User.create!(login: 'test_pilot', password: Rails.application.credentials.test_pilot_password)

rick = Member.create!(name: 'Rick Sanchez', url: 'https://rickandmorty.fandom.com/wiki/Rick_Sanchez')
doofus_rick = Member.create!(name: 'Rick Sanchez J19 Zeta 7', url: 'https://rickandmorty.fandom.com/wiki/Doofus_Rick')
morty = Member.create!(name: 'Morty Smith', url: 'https://rickandmorty.fandom.com/wiki/Morty_Smith')
jessica = Member.create!(name: 'Jessica', url: 'https://en.wikipedia.org/wiki/Kari_Wahlgren')
summer = Member.create!(name: 'Summer Smith', url: 'https://en.wikipedia.org/wiki/Spencer_Grammer')
jerry = Member.create!(name: 'Jerry Smith', url: 'https://en.wikipedia.org/wiki/Chris_Parnell')
beth = Member.create!(name: 'Beth Smith', url: 'https://en.wikipedia.org/wiki/Sarah_Chalke')
scary_terry = Member.create!(name: 'Scary Terry', url: 'https://en.wikipedia.org/wiki/Jess_Harnell')

rick.friends << morty
rick.friends << beth
morty.friends << jessica
morty.friends << summer
morty.friends << jerry
morty.friends << beth
beth.friends << jerry
jerry.friends << doofus_rick
