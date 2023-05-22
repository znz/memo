class Hoge
  def self.from_json(json:)
    JSON.parse(json, object_class: self)
  end
end

Hoge.from_json(json: "[hoge]").hoge
