orders = Order.generic
test_types = []
orders.each do |order|
  update = false
  order = order.as_json
  uuid = order['_id']

  if order['district'].blank?
    order['district'] = "Lilongwe"
    update = true
  end

  map = {
      "<OBR.4.2><OBR.4.2.1>Manual Differential </OBR.4.2.1><OBR.4.2.2> Cell Morphology</OBR.4.2.2></OBR.4.2>" =>  "Manual Differential & Cell Morphology",
      "<OBR.4.2><OBR.4.2.1>MC</OBR.4.2.1><OBR.4.2.2>S</OBR.4.2.2></OBR.4.2>" => "MC&S"
  }
  
  test_types = order['test_types']

  test_types.each do |test_type|

    if [
        "<OBR.4.2><OBR.4.2.1>Manual Differential </OBR.4.2.1><OBR.4.2.2> Cell Morphology</OBR.4.2.2></OBR.4.2>",
        "<OBR.4.2><OBR.4.2.1>MC</OBR.4.2.1><OBR.4.2.2>S</OBR.4.2.2></OBR.4.2>"
    ].include?(test_type)
        test_types[test_types.index(test_type)] = map[test_type]
        update = true
    end

    order['test_types'] = test_types
  end
  results = order["results"]

  change_keys = []
  results.each do |test_type, measures|
    if [
          "<OBR.4.2><OBR.4.2.1>Manual Differential </OBR.4.2.1><OBR.4.2.2> Cell Morphology</OBR.4.2.2></OBR.4.2>",
          "<OBR.4.2><OBR.4.2.1>MC</OBR.4.2.1><OBR.4.2.2>S</OBR.4.2.2></OBR.4.2>"
      ].include?(test_type)
        change_keys << test_type
    end
  end

  change_keys.each do |test_type|
    results[map[test_type]] = results[test_type]
    results.delete(test_type)
    update = true
  end

  order["results"] = results

  if update == true
    puts order['_id']
    url = "http://user:password@ipaddress:5984/lims_repo/"
    RestClient.post(url,  order.to_json, :content_type => "application/json")
  end
end
