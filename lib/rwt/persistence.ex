defmodule Rwt.Persistence do
  @table :rwt_persistence

  def save(key, data) do
    :dets.open_file(@table, [])
    :dets.insert(@table, {key, data})
    :dets.close(@table)
  end

  def read(key) do
    try do
      :dets.open_file(@table, [])
      [{key, data}] = :dets.lookup(@table, key)
      :dets.close(@table)
      data
    rescue
      _e ->
        nil
    end
  end
end
