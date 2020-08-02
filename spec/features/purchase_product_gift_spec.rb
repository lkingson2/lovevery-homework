require 'rails_helper'

RSpec.feature "Purchase Gift", type: :feature do
  scenario "Creates a gift order for an existing child" do
    product = Product.create!(
      name: "product1",
      description: "description2",
      price_cents: 1000,
      age_low_weeks: 0,
      age_high_weeks: 12,
    )

    child = Child.create!(
        full_name: "Chris Smith",
        birthdate: Date.new(2019,1,4),
        parent_name: "Sammi Johnson",
        address: "123 Some Road",
        zipcode: "90210",
    )

    visit "/"

    within ".products-list .product" do
      click_on "More Details…"
    end

    click_on "Buy Now $10.00"

    check "Is this a Gift?"

    fill_in "order[credit_card_number]", with: "4111111111111111"
    fill_in "order[expiration_month]", with: 12
    fill_in "order[expiration_year]", with: 25
    fill_in "order[shipping_name]", with: "Sammi Johnson"
    fill_in "order[billing_name]", with: "Bob Dylan"
    fill_in "order[address]", with: "123 Any St"
    fill_in "order[zipcode]", with: 83701
    fill_in "order[order_message]", with: "Hope Chris enjoys his new toy!"
    fill_in "order[child_full_name]", with: "Chris Smith"
    fill_in "order[child_birthdate]", with: "2019-01-04"

    click_on "Purchase"

    expect(page).to have_content("Thanks for Your Gift Order")
    expect(page).to have_content(Order.last.user_facing_id)
    expect(page).to have_content("Chris Smith")
    expect(page).to have_content("Hope Chris enjoys his new toy!")

  end

  scenario "Creates a gift order for a child not in our system" do
    product = Product.create!(
      name: "product1",
      description: "description2",
      price_cents: 1000,
      age_low_weeks: 0,
      age_high_weeks: 12,
    )

    visit "/"

    within ".products-list .product" do
      click_on "More Details…"
    end

    click_on "Buy Now $10.00"

    check "Is this a Gift?"

    fill_in "order[credit_card_number]", with: "4111111111111111"
    fill_in "order[expiration_month]", with: 12
    fill_in "order[expiration_year]", with: 25
    fill_in "order[shipping_name]", with: "Pat Jones"
    fill_in "order[address]", with: "123 Any St"
    fill_in "order[zipcode]", with: 83701
    fill_in "order[billing_name]", with: "Bob Dylan"
    fill_in "order[order_message]", with: "Hope Chris enjoys his new toy!"
    fill_in "order[child_full_name]", with: "Random Child"
    fill_in "order[child_birthdate]", with: "2019-03-03"

    click_on "Purchase"

    expect(page).not_to have_content("Thanks for Your Gift Order")
    expect(page).to have_content("To purchase a gift for a child they must already exist in our system. Please have their parent register them.")
  end
end
