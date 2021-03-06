<a href="http://travis-ci.org/#!/sathish316/totalr"><img src="https://travis-ci.org/sathish316/totalr.png"></img></a>

Totalr is a ruby library which gives a dsl that lets you do aggregations in your model declaratively.
It is inspired by the statistical capabilities of R. Currently it does not even do 1 % of what R does.

But it still lets you do aggregations like totaling, percentage, grouping in your model easily:

    class Team
      total :players, using: :goals, by: :age
    end

This creates a dynamic method total_player_goals_by_age which takes an age param.

    class Team
      percentage :total_player_goals, of: :total_player_attempts, as: :goals_to_attempts
    end

This creates a method which calculates percentage of goals:attempts for all players in the model.

Totalr does not serve to replace any aggregation mechanism already provided by ORM or Enumerable.
It only complements them by generating methods like this.

You can give custom names to generated methods using :as key
For documentation/features look at spec/totalr_spec.rb

More features like mean, variance are still under development.
