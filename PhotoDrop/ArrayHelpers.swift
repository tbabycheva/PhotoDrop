import Foundation

func update<T:Any>(
	_ new: [T]?,
	to old: [T]?,
	equals: ((T,T) -> Bool),
	remove: @escaping (T) -> Void,
	add: @escaping (T) -> Void
) {
	let old = old ?? []
	let new = new ?? []

  new.filter{(a) in !old.contains{equals(a,$0)}}.forEach{remove($0)}
	old.filter{(a) in !new.contains{equals(a,$0)}}.forEach{add($0)}
}
