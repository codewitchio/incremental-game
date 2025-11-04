# Autoloaded as Store
extends Node

# This is currently a global singleton, but if we want to store this we could make it a resource. 
# Unfortunately, autoloads have to be nodes. So we would need a wrapper. Then again, Store.Upgrades isn't so bad.
# The functionality here would then move to a GenericStore class. And the resources would be something like StoreResource.
# Is that too generic to be useful? Not sure. 

# Also, consider how a "lifetime score earned" stat would work. Something that subscribes to changes of score, but only counts positive changes?
# Where would we save it? In another StoreResource? Or in the same one, but with a different key? It could also be built into StoreValue, but I don't
# think we want to colocate current numbers with lifetime numbers. Harder to reset and "prestige" that way. But I don't like having to duplicate
# a lot of code and connect a lot of signals for it. If these were nodes, we could have a "LifetimeTracker" node and use composition to selectively add it.
# How can we use the principles of composition in generic classes? I guess StoreValue could have a boolean for whether it is tracked or not, and it communicates
# with the stats store. So logic is in StoreValue without the actual values having to be. 

# What other stats would we want to track? Time based stats like "score per second" is definitely one. 
# How should we? Compare delta "lifetime" score with delta time?

var _data: Dictionary = {
	"score": StoreValue.new(0.0),
}

## Sets the value of the given key to the given value.
func Set(key: String, value: Variant) -> void:
	_data[key].set_value(value)

## Gets the value of the given key.
func Get(key: String) -> Variant:
	if !Has(key):
		Loggie.error("%s is not a valid key" % key)
		return null

	return _data[key].get_value()

## Checks if the given key is in the store.
func Has(key: String) -> bool:
	return _data.has(key)

## Removes the given key from the store.
func Remove(key: String) -> void:
	_data.erase(key)

## Increments the value of the given key by the given amount.
func Increment(key: String, amount: float) -> void:
	var value: float = 0.0 if !Has(key) else Get(key)

	if value is float:
		Set(key, value + amount)
	else:
		Loggie.error("%s is not a float" % key)

## Registers a callback to be called when the value of the given key changes.
func Subscribe(key: String, callback: Callable) -> void:
	if !Has(key):
		Loggie.error("%s is not a valid key" % key)
		return

	_data[key].value_changed.connect(callback)
