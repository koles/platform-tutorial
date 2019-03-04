#!/usr/bin/env ruby

require 'gooddata'

die "Missing the 'AUTHORIZATION_TOKEN' environment variable." unless ENV['AUTHORIZATION_TOKEN']
project_title = ARGV.shift or "Retail Demo Workspace"
data_folder   = ARGV.shift or File.dirname($0)

puts "Data folder: #{data_folder}, $0 = #{$0}"

def add_attribute(dataset, identifier, options = {})
  attr_id = "attr.orders.#{identifier}"
  options[:anchor] ? dataset.add_anchor(attr_id, options) : dataset.add_attribute(attr_id, options)
  dataset.add_label("label.orders.#{identifier}", options.merge({ reference: attr_id }))
end

blueprint = GoodData::Model::ProjectBlueprint.build(project_title) do |p|
  p.add_dataset('dataset.orders', title: "Orders") do |d|
    add_attribute(d, "orderline_id", title: "Order Line ID", anchor: true )
    add_attribute(d, "order_id", title: "Order ID")
    add_attribute(d, "order_status", title: "Order Status")
    add_attribute(d, "campaign_category", title: "Campaign Category")
    add_attribute(d, "campaign_id", title: "Campaign ID")
    add_attribute(d, "campaign_name", title: "Campaign")
    add_attribute(d, "product_id", title: "Product ID")
    add_attribute(d, "product_name", title: "Product")
    add_attribute(d, "customer_id", title: "Customer ID")
    add_attribute(d, "customer_name", title: "Customer Name")
    add_attribute(d, "customer_state", title: "Customer State")
    d.add_fact("attr.orders.price", title: "Price")
    d.add_fact("attr.orders.quantity", title: "Quantity")
  end
end

client = GoodData.connect # reads credentials from ~/.gooddata
project = client.create_project_from_blueprint(blueprint, auth_token: ENV['AUTHORIZATION_TOKEN'])

data = [{
  data: "#{data_folder}/orders_tut_001.csv",
  dataset: 'dataset.orders'
}]

# Loading does not work yet
# result = project.upload_multiple(data, blueprint)
# pp result
# puts "Done!"