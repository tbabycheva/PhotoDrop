import Foundation

func update<T:Any>(
	_ new: [T]?,
	to old: [T]?,
	equals: ((T,T) -> Bool),
	remove: @escaping (T) -> Void,
  unchanged: @escaping (T,T) -> Void = { (_,_) in },
	add: @escaping (T) -> Void
) {
	let old = old ?? []
	let new = new ?? []

  new.filter{(t) in !old.contains{equals(t,$0)}}.forEach{remove($0)}
	old.filter{(t) in !new.contains{equals(t,$0)}}.forEach{add($0)}

  for tOld in old {
    if let tNew = new.first(where: {equals(tOld,$0)}) {
      unchanged(tOld, tNew)
    }
  }
}
