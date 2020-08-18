module Exportable

  require 'csv'
  
  def to_csv(objects)
    attributes = self::EXPORTABLE_COLUMNS

    CSV.generate(headers: true) do |csv|
      csv << attributes.map(&:camelcase)

      objects.each do |object|
        csv << attributes.map{ |attr| object.send(attr) }
      end
    end
  end
end