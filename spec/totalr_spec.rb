require 'spec_helper'


describe Totalr do

  class Team
    include Totalr
    attr_accessor :players

    def initialize(params)
      @name = params[:name]
      @players = []
    end
  end

  class Player
    attr_reader :goals
    attr_reader :attempts
    attr_reader :age
    attr_reader :region
    def initialize(params)
      @name = params[:name]
      @goals = params[:goals]
      @attempts = params[:attempts]
      @age = params[:age]
      @region = params[:region]
    end

  end

  describe "total" do

    class Team
      total :players
    end

    it "should total collection" do
      real_madrid = Team.new(name: 'Real Madrid')
      real_madrid.players << Player.new(name: 'Ronaldo')
      real_madrid.players << Player.new(name: 'Beckham')

      real_madrid.total_players.should == 2
    end

    class Team
      total :players, as: :player_count
    end

    it "should total collection with custom name" do
      real_madrid = Team.new(name: 'Real Madrid')
      real_madrid.players << Player.new(name: 'Ronaldo')
      real_madrid.players << Player.new(name: 'Beckham')

      real_madrid.player_count.should == 2
    end

    class Team
      total :players, using: :goals
    end

    it "should total collection using attribute" do
      real_madrid = Team.new(name: 'Real Madrid')
      real_madrid.players << Player.new(name: 'Ronaldo', goals: 25)
      real_madrid.players << Player.new(name: 'Beckham', goals: 15)

      real_madrid.total_player_goals.should == 40
    end

    class Team
      total :players, using: :goals, as: :number_of_goals
    end

    it "should total collection using attribute with custom name" do
      real_madrid = Team.new(name: 'Real Madrid')
      real_madrid.players << Player.new(name: 'Ronaldo', goals: 25)
      real_madrid.players << Player.new(name: 'Beckham', goals: 15)

      real_madrid.number_of_goals.should == 40
    end

    class Team
      total :players, by: :age
    end

    it "should total collection grouping by attribute" do
      real_madrid = Team.new(name: 'Real Madrid')
      real_madrid.players << Player.new(name: 'Ronaldo', age: 25)
      real_madrid.players << Player.new(name: 'Beckham', age: 25)
      real_madrid.players << Player.new(name: 'Figo', age: 30)

      real_madrid.total_players_for_age(25).should == 2
      real_madrid.total_players_for_age(30).should == 1
    end

    class Team
      total :players, using: :goals, by: :age
    end

    it "should total collection mapping by attribute and grouping by attribute" do
      real_madrid = Team.new(name: 'Real Madrid')
      real_madrid.players << Player.new(name: 'Ronaldo', goals: 25, age: 25)
      real_madrid.players << Player.new(name: 'Beckham', goals: 15, age: 25)
      real_madrid.players << Player.new(name: 'Figo', goals: 10, age: 30)

      real_madrid.total_player_goals_for_age(25).should == 40
      real_madrid.total_player_goals_for_age(30).should == 10
    end

  end

  describe "percentage" do
    class Team
      total :players
      total :players, by: :age
      percentage :total_players_for_age, by: :age, of: :total_players
    end

    it "should calculate percentage of total" do
      real_madrid = Team.new(name: 'Real Madrid')
      real_madrid.players << Player.new(name: 'Ronaldo', age: 25)
      real_madrid.players << Player.new(name: 'Beckham', age: 25)
      real_madrid.players << Player.new(name: 'Figo', age: 30)

      real_madrid.percentage_total_players_for_age(25).round(2).should == 66.67
      real_madrid.percentage_total_players_for_age(30).round(2).should == 33.33
    end

    class Team
      percentage :total_players_for_age, by: :age, of: :total_players, as: :distribution_by_age
    end

    it "should calculate percentage of total with custom name" do
      real_madrid = Team.new(name: 'Real Madrid')
      real_madrid.players << Player.new(name: 'Ronaldo', age: 25)
      real_madrid.players << Player.new(name: 'Beckham', age: 25)
      real_madrid.players << Player.new(name: 'Figo', age: 30)

      real_madrid.distribution_by_age(25).round(2).should == 66.67
      real_madrid.distribution_by_age(30).round(2).should == 33.33
    end

    class Team
      percentage :total_player_goals_for_age, by: :age, of: :total_player_goals, as: :percentage_goals_by_age
    end

    it "should calculate percentage of total using attribute" do
      real_madrid = Team.new(name: 'Real Madrid')
      real_madrid.players << Player.new(name: 'Ronaldo', goals: 25, age: 25)
      real_madrid.players << Player.new(name: 'Beckham', goals: 15, age: 25)
      real_madrid.players << Player.new(name: 'Figo', goals: 10, age: 30)

      real_madrid.percentage_goals_by_age(25).should == 80.00
      real_madrid.percentage_goals_by_age(30).should == 20.00
    end

    class Team
      total :players, using: :goals, by: :region
      percentage :total_player_goals_for_age, by: :age,
                    of: :total_player_goals_for_region, total_by: :region
    end

    it "should calculate percentage totaling by attribute" do
      real_madrid = Team.new(name: 'Real Madrid')
      real_madrid.players << Player.new(name: 'Ronaldo', goals: 25, age: 28, region: 'southamerica')
      real_madrid.players << Player.new(name: 'Beckham', goals: 20, age: 25, region: 'europe')
      real_madrid.players << Player.new(name: 'Carlos', goals: 10, age: 28, region: 'southamerica')
      real_madrid.players << Player.new(name: 'Figo', goals: 12, age: 30, region: 'europe')
      real_madrid.players << Player.new(name: 'Zidane', goals: 18, age: 30, region: 'europe')

      real_madrid.percentage_total_player_goals_for_age_in_region(30, 'europe').should == 60.00
      real_madrid.percentage_total_player_goals_for_age_in_region(25, 'europe').should == 40.00
    end

    class Team
      total :players, using: :goals, by: :age
      total :players, using: :attempts, by: :age
      percentage :total_player_goals_for_age, by: :age,
                    of: :total_player_attempts_for_age, total_by: :age,
                    as: :goal_to_attempts

    end

    it "should calculate percentage totaling by same attribute as percentage" do
      real_madrid = Team.new(name: 'Real Madrid')
      real_madrid.players << Player.new(name: 'Ronaldo', goals: 21, attempts: 30, age: 25)
      real_madrid.players << Player.new(name: 'Beckham', goals: 15, attempts: 20, age: 25)
      real_madrid.players << Player.new(name: 'Figo', goals: 10, attempts: 15, age: 30)

      real_madrid.goal_to_attempts(25).should == 72.00
    end
  end

end
