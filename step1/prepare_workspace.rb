#!/usr/bin/env ruby

require 'gooddata'

GoodData.logging_http_on

die "Missing the 'AUTHORIZATION_TOKEN' environment variable." unless ENV['AUTHORIZATION_TOKEN']
project_title = ARGV.shift || "Retail Demo Workspace"
data_folder   = ARGV.shift || '.'

puts "Data folder: #{data_folder}, project = #{project_title}, $0 = #{$0}"

def add_attribute(dataset, identifier, options = {})
  attr_id = "attr.orders.#{identifier}"
  options[:anchor] ? dataset.add_anchor(attr_id, options) : dataset.add_attribute(attr_id, options)
  dataset.add_label("label.orders.#{identifier}", options.merge({ reference: attr_id }))
end

blueprint = GoodData::Model::ProjectBlueprint.build(project_title) do |p|
  p.add_dataset('dataset.orders', title: "Orders") do |d|
    p.add_date_dimension('ordered_at', title: 'Ordered at')
    add_attribute(d, "order_line_id", title: "Order Line ID", anchor: true )
    add_attribute(d, "order_id", title: "Order ID")
    d.add_date('ordered_at', format: 'yyyy-MM-dd')
    add_attribute(d, "order_status", title: "Order Status")
    add_attribute(d, "customer_id", title: "Customer ID")
    add_attribute(d, "fullname", title: "Customer Name")
    add_attribute(d, "state", title: "Customer State")
    add_attribute(d, "product_id", title: "Product ID")
    add_attribute(d, "product_name", title: "Product")
    add_attribute(d, "category", title: "Product Category")    
    d.add_fact("fact.orders.price", title: "Price")
    d.add_fact("fact.orders.quantity", title: "Quantity")
    add_attribute(d, "campaign_id", title: "Campaign ID")
    add_attribute(d, "channel", title: "Channel")
    d.add_fact("fact.orders.budget", title: "Quantity")
  end
end

client = GoodData.connect # reads credentials from ~/.gooddata
project = ENV['WORKSPACE'] ? client.projects(ENV['WORKSPACE']) : client.create_project_from_blueprint(blueprint, auth_token: ENV['AUTHORIZATION_TOKEN'])

data = [{
  data: "#{data_folder}/orders_tut_001_columns.csv",
  dataset: 'dataset.orders'
}]

result = project.upload_multiple(data, blueprint)
pp result
puts "Done!"