# LibSpellButton
A helper library to create buttons to cast spells

The library is made in object-oriented style where you call CreateSpellButton which returns a SpellButton object.

Sample:
```
button = _G.LibStub('LibSpellButton-1').CreateSpellButton(6991, "FeedPetButton", 64, 64)
button:setPoint("LEFT", _G.PetFrameHappiness, "RIGHT", 20, 0);
```