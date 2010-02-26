require "savageworlds"
require "savageworlds_core_weapons"

include SavageWorlds

ch = Character.new("Geoffryn", true,
  {
    :strength => :d6,
    :agility  => :d6,
    :smarts   => :d4,
    :spirit   => :d8,
    :vigor    => :d10
  },
  {
    :fighting => :d8,
    :survival => :d6,
    :shooting => :d6
  },
  {
    :edges => ["Toughness"],
    :hindrances => ["Loyal"]
  }
)

ch.add_edge("Battle Bunny")
ch.add_edge("Unmoveable")
ch.add_hindrance("Brain Damage")

puts ch

tr = ch.trait_roll(:strength)
puts "Strength Check for #{ch.name}:"
puts "%-10s: %s" % [ch.strength, tr.trait.total]
puts "%-10s: %s" % ["Wild Die", tr.wild_die.total]

puts ""
puts "Parry: #{ch.parry}"
puts "Toughness: #{ch.toughness}"

sword = MeleeWeapons[:long_sword]
bow = RangeWeapons[:bow]

puts ""
puts sword
puts ""
dmg = sword.roll_damage(ch.get_trait(:strength)).total
puts "%s: %s" % ["Damage Roll", dmg]

puts ""
puts bow
puts ""
dmg = bow.roll_damage.total
puts "%s: %s" % ["Damage Roll", dmg]


