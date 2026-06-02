# Exemplo de uso do FatSecretApiService
# Execute no console Rails: rails runner demo_fatsecret.rb

require_relative 'app/services/fat_secret_api_service'

service = FatSecretApiService.new
# exemplo de uso com food_id
food_id = 33691
response = service.get_food(food_id)
puts JSON.pretty_generate(response)
