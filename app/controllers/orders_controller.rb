class OrdersController < ApplicationController
  def new
    @order = Order.new(product: Product.find(params[:product_id]))
  end

  def create
    child = Child.find_by(child_params)
    if params[:order][:order_type].eql? "gift"

      if child.nil?
        flash[:error] = "To purchase a gift for a child they must already exist in our system. Please have their parent register them."
        redirect_to new_order_path(product_id: params[:order][:product_id]) and return
      else
        # Copy the address into the billing fields
        params[:order][:billing_address] = params[:order][:address]
        params[:order][:billing_zipcode] = params[:order][:zipcode]

        # Copy the child's address into the shipping fields
        params[:order][:address] = child[:address]
        params[:order][:zipcode] = child[:zipcode]
      end
    else
      if child.nil?
        child = Child.find_or_create_by(child_params.merge(address: params[:order][:address], zipcode: params[:order][:zipcode]))
      elsif child[:address] != params[:order][:address] or child[:zipcode] != params[:order][:zipcode]
        flash[:error] = "A child already exists with this name and birthdate at a different address. Please use the correct address."
        redirect_to new_order_path(product_id: params[:order][:product_id]) and return
      end

      # If order is not a gift set the billing as the shipping name
      params[:order][:billing_name] = params[:order][:shipping_name]

      # Copy the child's address into the billing fields
      params[:order][:billing_address] = child[:address]
      params[:order][:billing_zipcode] = child[:zipcode]
    end
    @order = Order.create(order_params.merge(child: child, user_facing_id: SecureRandom.uuid[0..7], billing_zipcode: params[:order][:billing_zipcode], billing_address: params[:order][:billing_address]))
    if @order.valid?
      Purchaser.new.purchase(@order, credit_card_params)
      redirect_to order_path(@order)
    else
      render :new
    end
  end

  def show
    @order = Order.find_by(id: params[:id]) || Order.find_by(user_facing_id: params[:id])
  end

private

  def order_params
    params.require(:order).permit(:shipping_name, :product_id, :zipcode, :address, :order_type, :order_message, :billing_name).merge(paid: false)
  end

  def child_params
    {
      full_name: params.require(:order)[:child_full_name],
      parent_name: params.require(:order)[:shipping_name],
      birthdate: Date.parse(params.require(:order)[:child_birthdate]),
    }
  end

  def credit_card_params
    params.require(:order).permit( :credit_card_number, :expiration_month, :expiration_year)
  end
end
