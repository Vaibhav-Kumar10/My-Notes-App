// Targeted by Stream<List<T>> where T is any type
// e.g., Stream<List<DatabaseNote>>
// Returns a stream that contains only the items that satisfy the given predicate - where
extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) where) =>
      map((item) => item.where(where).toList());
}
