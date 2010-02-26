=begin rdoc

A Savage Worlds Ruby library. 
This library hopes to encapsulate and model the concepts for characters
and gear in the Savage Worlds Expedition version of the RPG.  It's probably
not complete, but it's useable.

This module depends on my +dicelib+ library.

*TODO:* put urls, etc, here.

Author::  Randy Carnahan
Version:: 1.0b
License:: GPLv2

=end

# The main Savage Worlds module. Holds the classes and helper methods.
module SavageWorlds

  require "dicelib"
  require "savageworlds_dice"

  include Dice

  # Generic Savage Worlds error.
  class SWError < Exception
  end

  # Used in +trait_string+ to split a string into one or more parts. It 
  # splits based on one or more spaces or an underscore.
  TraitSplitRE = /\s+|_/

  # Helper method to make a SW appropriate dice_string for
  # non-trait dice. The 'dice' argument _should_ be an
  # instance of Dice::DiceParts, Roll::Roll or a String.
  # Handy for making SW-esque dice (using the 'e' option) into
  # 'normal' dice strings. IE: 
  #
  #   1d6e => d6
  def make_dice_string(dice)
    dice = dice.dup()

    case dice
    when Dice::DiceParts
      # pass
    when Roll
      dice = dice.dice_parts()
    when String
      dice = parse_dice_string(dice)
    else
      raise SWError, "Argument not a Dice::DiceParts, Roll::Roll or String instance!"
    end

    dice[:num] = 0
    dice[:explode] = 0
    return build_dice_string(dice)
  end

  # Takes a trait string, and after checking if it's
  # already a  symbol, an empty string, or not a string 
  # instance, replaces spaces with an underscore, 
  # downcases it, and turns it into a symbol.
  # Returns +nil+ if it fails any of those tests.
  def trait_to_symbol(trait="")
    return trait if trait.class == Symbol
    return nil if trait.empty? or trait.nil? or trait.class != String
    return trait.gsub(/\s+/, "_").downcase.to_sym()
  end

  # Takes a symbol, turns it into a string, splits it
  # based on the +TraitSplitRE+ regex above, collects 
  # each word and capitalizes them, then returns them 
  # joined by spaces.
  def trait_string(trait)
    trait = trait.to_s.split(TraitSplitRE).collect do |str|
      str.capitalize()
    end
    return trait.join(" ")
  end

  # Checks to see if the given trait, a symbol, is in the
  # +AllowedDice+ hash.
  def valid_trait_score?(trait)
    return trait if AllowedDice.has_key?(trait)
  end

  # Checks to see if a roll resulted in any Raises, and returns
  # how many were found, or 0 if there were none.
  #
  # roll:: The value rolled.
  # target_number:: The value to beat, defaulting to 4.
  def get_raises(roll, target_number=4)
    return (roll - target_number) / 4
  end

  # Models a Savage Worlds character, in a mostly generic way.
  class Character

    # The read-only attributes.
    # Skills, Edges and Hindrances have their own 
    # access methods.
    attr_reader :name, :skills, :edges, :hindrances

    # These can be changed. For now.
    # XXX I might override these so I can do some
    # checking of assigned values. Right now this makes it 
    # easy and convient to do mass-assignement.
    attr_accessor :agility, :smarts, :spirit, :strength, :vigor

    # To hold the results of a trait roll. 
    TraitResult = Struct.new(:trait, :wild_die)

    # The Character constructor.
    #
    # +name+::
    #   The name of the character.
    # +wild+::
    #   A boolean; if true, this character is a Wild Card.
    # +stats+::
    #   A hash containing the primary traits of the character, with
    #   each trait as the key (a string or symbol) and a die-value
    #   (one of the +AllowedDice+ keys) as the values.
    # +skills+::
    #   A hash where each key is a skill name and each value a die-value
    #   from AllowedDice, like +stats+ above. 
    # +others+::
    #   A hash containining optional other values. Currently,
    #   only _two_ values are checked for: Edges and Hindrances.
    #   +edges+:: Contains an array of Edge names.
    #   +hindrances+:: Contains an array of Hindrance names.
    def initialize(name, wild=false, stats={}, skills={}, others={})
      @name = name
      @wildcard = wild
      @skills = {}
      @edges = []
      @hindrances = []

      stats.keys.each do |stat|
        st = "#{stat}="
        if self.respond_to?(st)
          die = valid_trait_score?(stats[stat])
          die = :d6 if die.nil?
          self.send(st, die)
        end
      end

      skills.each do |skill, die|
        self.add_skill(skill, die)
      end

      if others.has_key?(:edges)
        others[:edges].each do |edge|
          self.add_edge(edge)
        end
      end

      if others.has_key?(:hindrances)
        others[:hindrances].each do |hindrance|
          self.add_hindrance(hindrance)
        end
      end

    end

    # Just to keep this Ruby-esque
    def is_wildcard?
      return @wildcard
    end

    def stats
      return [:agility, :smarts, :spirit, 
        :strength, :vigor
      ].inject({}) do |d, stat|
        d[stat] = self.send(stat)
        d
      end
    end

    def get_trait(trait)
      trait = trait_to_symbol(trait)
      # Look for attributes first, then for skills.
      if self.respond_to?(trait)
        return AllowedDice[self.send(trait)]
      elsif @skills.has_key?(trait)
        return AllowedDice[@skills[trait]]
      end
      # Not found, return nil.
      return
    end

    def trait_roll(trait, mod=0)
      result = TraitResult.new()

      die = get_trait(trait)

      if die.nil?
        result.trait = NoTrait.roll(mod)
      else
        result.trait = die.roll(mod)
      end

      if @wildcard
        if die.nil?
          result.wild_die = WildDieNoTrait.roll(mod)
        else
          result.wild_die = WildDie.roll(mod)
        end
      end

      return result
    end

    def has_skill?(skill)
      skill = trait_to_symbol(skill)
      return true if @skills.has_key?(skill)
      return false
    end

    def add_skill(skill, die)
      skill = trait_to_symbol(skill)
      die = valid_trait_score?(die) or NoTrait
      @skills[skill] = die
      return self
    end

    def remove_skill(skill)
      skill = trait_to_symbol(skill)
      return @skills.delete(skill)
    end

    def add_edge(edge="")
      edge = trait_string(edge)
      if edge.any?
        @edges.push(edge)
        @edges.sort!
      end
      return self
    end

    def remove_edge(edge="")
      edge = trait_string(edge)
      if edge.any?
        @edges.reject! do |e|
          e == edge
        end
      end
      return self
    end
 
    def add_hindrance(hindrance="")
      hindrance = trait_string(hindrance)
      if hindrance.any?
        @hindrances.push(hindrance)
        @hindrances.sort!
      end
      return self
    end

    def remove_hindrance(hindrance="")
      hindrance = trait_string(hindrance)
      if hindrance.any?
        @hindrances.reject! do |h|
          h == hindrance
        end
      end
    end

    def parry
      p = 2
      f = get_trait(:fighting)
      p = 2 + f.half_value() if f and f != NoTrait
      return p
    end

    def toughness
      t = 2 + get_trait(:vigor).half_value()
    end

    # Used for printing the character as a simple text
    # representation. 
    def to_s

      # Proc object to reduce redundant code, used to 
      # print a simple title followed by a line of 30
      # dash marks on the following line.
      title = Proc.new do |t|
        t.center(30) + "\n" + "-" * 30 + "\n"
      end
      
      s = self.name
      s += " (Wild Card)" if @wildcard
      s += "\n\n"

      s += title.call("Stats")
      [:agility, :smarts, :spirit, :strength, :vigor].each do |st|
        s += "%-24s: %s\n" % [trait_string(st), self.send(st)]
      end
      s += "\n"

      s += title.call("Skills")
      skills = @skills.keys.collect do |sk|
        # A simple Symbol to String conversion.
        # We have to do this, since Symbols are not
        # sortable.
        # XXX Maybe feed this to trait_string()? 
        sk.to_s() 
      end
      # Sort in-place
      skills.sort!
      skills.each do |sk|
        s += "%-24s: %s\n" % [trait_string(sk), @skills[sk.to_sym()]]
      end
      s += "\n"

      s += title.call("Edges & Hindrances")
      @edges.each do |edge|
        s += edge + "\n"
      end

      @hindrances.each do |hind|
        s += hind + "\n"
      end
      s += "\n"
      
      return s
    end

  end

  class Gear
    attr :name

    def initialize(name, options={})
      @name = name
      @options = {}.update(options)
    end

    def has_trait?(trait)
      trait = trait_to_symbol(trait) if trait.class != Symbol
      return true if @options.has_key?(trait)
    end

    def get_trait(trait, default=nil)
      trait = trait_to_symbol(trait)
      return @options[trait] if has_trait?(trait)
      return default
    end

    def get_number_trait(trait, default=0)
      return get_trait(trait, default)
    end

    def get_string_trait(trait, default="")
      return get_trait(trait, default)
    end

    def cost
      return get_number_trait(:cost)
    end

    def description
      return get_string_trait(:description)
    end

    def notes
      return get_string_trait(:notes)
    end

    def weight
      return get_number_trait(:weight)
    end

    def to_s
      s = "#{trait_string(@name)}\n" + ("-" * 10) + "\n"
      if self.has_trait?(:description)
        s += "#{self.description}\n"
      end
      return s
    end
  end

  class BasicWeapon < Gear
    attr_reader :damage

    WeaponResult = Struct.new(:total, :damage)

    def initialize(name, damage, options={})
      if AllowedDice.has_key?(damage)
        @damage = AllowedDice[damage]
      else
        @damage = SWRoll.new(damage, true)
      end
      super(name, options)
    end

    def is_heavy_weapon?
      return has_trait?(:heavy_weapon)
    end

    def armor_piercing
      return get_number_trait(:armor_piercing)
    end

    def minimum_strength
      return get_trait(:minimum_strength, :d4)
    end

    def roll_damage(mod=0)
      dmg = @damage.roll(mod)
      return WeaponResult.new(dmg.total, dmg)
    end

    def damage_string
      return make_dice_string(@damage)
    end

    def to_s
      s = super()
      s += "%-20s: %s\n" % ["Damage", damage_string()]

      keys = @options.keys.collect do |key|
        trait_string(key)
      end

      keys.sort!

      keys.each do |key|
        key_sym = trait_to_symbol(key)
        next if key_sym == :description
        value = @options[key_sym]
        value = value.join("/") if value.class == Array
        s += "%-20s: %s\n" % [key, value]
      end
      return s
    end

  end

  class MeleeWeapon < BasicWeapon
    MeleeResult = Struct.new(:total, :strength, :damage)

    def roll_damage(str, mod=0)
      str_roll = str.roll()
      dmg_roll = @damage.roll()

      t = str_roll.total + dmg_roll.total + mod
      result = MeleeResult.new(t, str_roll, dmg_roll)
      return result
    end

    def damage_string
      return "Str+" + super()
    end

    def parry
      return get_number_trait(:parry)
    end

    def reach
      return get_number_trait(:reach)
    end

  end

  class RangeWeapon < BasicWeapon
    RangeResult = Struct.new(:total, :damage)

    # We have a local constructor, so we can test
    # for a range option.
    def intialize(name, damage, options={})
      if options.has_key?(:range)
        range = options[:range]

        # Make sure we have 3 ranges...
        if range.class != Array or range.length != 3
          raise SWError, "RangeWeapon requires a :range option of 3 elements!"
        end

        # ...and then make sure they are integers.
        range.collect! do |r|
          r.to_i()
        end
      else
        range = [0, 0, 0]
      end
      options[:range] = range
      super(name, damage, options)
    end

    def range
      r = get_trait(:range, [0, 0, 0])
      return r.join("/")
    end

    def rate_of_fire
      return get_number_trait(:rate_of_fire)
    end

    def shots
      return get_number_trait(:shots)
    end

  end

end

