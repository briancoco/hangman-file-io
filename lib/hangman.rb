require 'yaml'

class Game

    attr_accessor :wrong_guess, :right_guess, :guess, :current_display
    attr_reader :secret

    def initialize() 
        @wrong_guess = 0
        @right_guess = []
        @secret = choose_secret()
        @guess = ''
        @current_display = ''
    end
    #game logic 
    def play()
        load()
        until winner?() || wrong_guess == 5 do
            turn()
        end
        if wrong_guess == 5
            current_display
            puts "Out of tries! Better luck next time."
        end
    end
    #game logic for each turn
    def turn()
        #if this is the first turn, print out # of letters in word
        if current_display == ''
            update_display()
        end
        ask_guess()
        check_guess()
        update_display()
        save()
    end

    def choose_secret() 
        words = File.readlines('words.txt')
        #random word, subbing out new line escape char
        word = words[rand(words.length)].gsub("\n", '')
        #randomly selects a word between 5 and 12 characters
        until word.length >= 5 && word.length <= 12 do
            word = words[rand(words.length)].gsub("\n", '')
        end 
        word
    end

    def ask_guess()
        print "Enter your guess: "
        self.guess = gets.chomp.downcase
        #while the guess is not a valid character or is greater than 1 char
        #ask for guess again
        while guess.match?(/[^a-z]/) || guess.length != 1 do
            print "Invalid guess, try again: "
            self.guess = gets.chomp.downcase
        end
    end

    def check_guess()
        if secret.include?(guess)
            right_guess.push(guess)
            puts "Right!"
        else  
            self.wrong_guess += 1
            puts "Wrong."
        end
    end

    def update_display()
        self.current_display = ''
        for i in secret.split('') do
            if right_guess.include?(i)
                self.current_display += i
            else  
                self.current_display += "_"
            end
        end
        puts current_display.split('').join(' ')
    end

    def winner?()
        if current_display == secret 
            puts 'You Win!'
            return true
        end 
        return false
    end

    def save()
        print "Do you want to save game? (Y or N): "
        answer = gets.chomp.upcase
        until answer == 'Y' || answer == 'N' do
            print "Invalid answer, Do you want to save game? (Y or N): "
            answer = gets.chomp.upcase
        end
        #if yes, open save file and save serialized game data
        if answer == 'Y'
            save_file = File.open('save.yaml', 'w')
            save_file.puts(to_yaml())
            save_file.close
        end
    end

    def load()
        print "Do you want to load game save? (Y or N): "
        answer = gets.chomp.upcase
        until answer == 'Y' || answer == 'N' do
            print "Invalid answer, Do you want to load game save? (Y or N): "
            answer = gets.chomp.upcase
        end
        #if yes, updates game data and display
        if answer == 'Y'
            from_yaml()
            update_display()
        end
    end

    def to_yaml()
        YAML.dump ({
            :wrong_guess => @wrong_guess,
            :right_guess => @right_guess,
            :secret => @secret,
            :guess => @guess,
            :current_display => @current_display
        })
    end

    def from_yaml()
        load_file = YAML.load File.read('save.yaml')
        @wrong_guess = load_file[:wrong_guess]
        @right_guess = load_file[:right_guess]
        @secret = load_file[:secret]
        @guess = load_file[:guess]
        @current_display = load_file[:current_display]
    end

end

game = Game.new
game.play()