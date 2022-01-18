#  File:                RPG.py
#  Description:         Auto Role playging game
#  Name:                Ben Doherty



class Weapon:

    # So that I can reference the weapon later by name rather than the
    # <__main__.Weapon object at 0x7eaed2c2dc88> value apearing
    def __str__(self):
        return self.weaponClass
    
    def __init__(self, weaponClass):
        self.weaponClass = weaponClass

        # defining all the acceptable weapons and their damage
        try: 
            if weaponClass.lower() == "dagger":
                self.damage = 4
            elif weaponClass.lower() == "axe":
                self.damage = 6
            elif weaponClass.lower() == "staff":
                self.damage = 6
            elif weaponClass.lower() == "sword":
                self.damage = 10
            elif weaponClass.lower() == "none":
                self.damage = 1
            else:
                raise NameError("Not a valid weapon")
        except NameError:
            print("\'"+str(self.weaponClass)+"\' is not a valid weapon")


# Same basic thing as weapons but different values and names
class Armor:

    def __str__(self):
        return self.armorClass

    def __init__(self,armorClass):
        self.armorClass = armorClass

        try:
            if armorClass.lower() == "plate":
                self.AC = 2
            elif armorClass.lower() == "chain":
                self.AC = 5
            elif armorClass.lower() == "leather":
                self.AC = 8
            elif armorClass.lower() == "none":
                self.AC = 10
            else:
                raise NameError("Not a valid armor")
        except NameError:
            print("\'"+str(self.armorClass)+"\' is not a valid armor")
    

class RPGCharacter:
    
    def __str__(self):
        disc = "\n" + self.name + "\n   " + \
            "Current Health: " + str(self.currentHealth) +"\n   " + \
            "Current Spell Points: " + str(self.currentSpell) + "\n   " + \
            "Wielding: " + str(self.weapon) + "\n   " + \
            "Wearing: " + str(self.armor) + "\n   " + \
            "Armor Class: " + str(self.armor.AC) + "\n"
        return disc

    def checkForDefeat(self):
        if self.currentHealth <= 0:
            print(self.name+" has been defeated!")

    # Class charactor defines the allowable weapons, will assert error if
    #  not allowed otherwise we equipt their weapon
    def wield(self, weapon):
        try:
            assert str(weapon) in self.allowedWeapon
            self.weapon = weapon
            print(self.name+" is now wielding a(n) "+str(self.weapon))
            
        except AssertionError:
            print("Weapon not allowed for this character class.")

    def unwield(self):
        self.weapon = Weapon("none")
        print(self.name+" is no longer wielding anything")

    # Same for wield but w/t armor
    def putOnArmor(self, armor):
        try:
            assert str(armor) in self.allowedArmor
            self.armor = armor
            print(self.name+" is now wearing "+str(self.armor))
        except AssertionError:
            print("Armor not allowed for this character class.")

    def takeOffArmor(self):
        self.armor = Armor("none")
        print(self.name+" is no longer wearing anything")

    def fight(self, person):
        print(self.name+" attacks "+person.name+" with a(n) "+str(self.weapon))
        person.currentHealth -= self.weapon.damage # target takes damage
        print(self.name+" does "+str(self.weapon.damage)+" damage to "+\
              person.name)
        print(person.name+" is now down to "+str(person.currentHealth)+" health")
        person.checkForDefeat()

# Set the default values and allowable weapons/armor of fighters and wizards            
class Fighter(RPGCharacter):

    maxHealth = 40
    maxSpell = 0

    def __init__(self,name):
        self.name = name

        self.currentHealth = self.maxHealth
        self.currentSpell = self.maxSpell
        self.weapon = Weapon("none")
        self.armor = Armor("none")
        self.allowedWeapon = ["none","sword","staff","axe","dagger"]
        self.allowedArmor = ["none","leather","chain","plate"]

class Wizard(RPGCharacter):

    maxHealth = 16
    maxSpell = 20
        
    def __init__(self,name):
        self.name = name

        self.currentHealth = self.maxHealth
        self.currentSpell = self.maxSpell
        self.weapon = Weapon("none")
        self.armor = Armor("none")
        self.allowedWeapon = ["none","staff","dagger"]
        self.allowedArmor = ["none"]

    # Raise error is using wrong spell or not enough mana
    # Will assign cost and effect for each spell
    # Take away the mana and health, making sure not to go over max health
    # Finally describe the spell cast
    def castSpell(self,spell,target):
        try:
            print(self.name+" casts "+spell+" at "+target.name)

            if spell.lower() == "fireball":
                cost,effect = 3,5
            elif spell.lower() == "lightning bolt":
                cost,effect = 10,10
            elif spell.lower() == "heal":
                cost,effect = 6,-6
            else:
                raise NameError("Not a valid spell")

            if cost > self.currentSpell:
                raise IndexError("Not enough mana")
            else:
                self.currentSpell -= cost
                target.currentHealth -= effect

                if target.currentHealth > target.maxHealth:
                    target.currentHealth = target.maxHealth
            if spell.lower() == "heal":
                print(self.name+" heals "+target.name+" for 6 health points.")
                print(self.name+" is now at "+str(self.currentHealth)+" health")
            else:
                print(self.name+" does "+str(effect)+" damage to "+target.name)
                print(target.name+" is now down to "+str(target.currentHealth)\
                      +" health")
                target.checkForDefeat()
            
        except NameError:
            print("Unknown spell name. Spell failed")
        except IndexError:
            print("Insufficient spell points")

def main():

    plateMail = Armor("plate")
    chainMail = Armor("chain")
    sword = Weapon("sword")
    staff = Weapon("staff")
    axe = Weapon("axe")

    gandalf = Wizard("Gandalf the Grey")
    gandalf.wield(staff)
    
    aragorn = Fighter("Aragorn")
    aragorn.putOnArmor(plateMail)
    aragorn.wield(axe)
    
    print(gandalf)
    print(aragorn)

    gandalf.castSpell("Fireball",aragorn)
    aragorn.fight(gandalf)

    print(gandalf)
    print(aragorn)
    
    gandalf.castSpell("Lightning Bolt",aragorn)
    aragorn.wield(sword)

    print(gandalf)
    print(aragorn)

    gandalf.castSpell("Heal",gandalf)
    aragorn.fight(gandalf)

    gandalf.fight(aragorn)
    aragorn.fight(gandalf)

    print(gandalf)
    print(aragorn)



main()
