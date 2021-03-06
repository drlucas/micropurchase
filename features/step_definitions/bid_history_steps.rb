Then(/^I should see the bid history$/) do
  within('.usa-table-borderless') do
    expect(page).to have_content('Bidder')
  end
end

Then(/^I should be able to see the full details for each bid$/) do
  # sort the bids so that newest is first
  bids = @auction.bids.order(created_at: :desc)

  # ensure the table has the correct content, in the correct order
  bids.each_with_index do |bid, i|
    row_number = i + 1
    unredacted_bidder_name = bid.bidder.name
    unredacted_bidder_duns = bid.bidder.duns_number

    # check the "name" column
    within(:xpath, cel_xpath(row: row_number, column: 1)) do
      expect(page).to have_content(unredacted_bidder_name)
    end

    within(:xpath, cel_xpath(row: row_number, column: 2)) do
      expect(page).to have_content(unredacted_bidder_duns)
    end

    # check the "amount" column
    amount = ApplicationController.helpers.number_to_currency(bid.amount)
    within(:xpath, cel_xpath(row: row_number, column: 3)) do
      expect(page).to have_content(amount)
    end

    # check the "date" column
    within(:xpath, cel_xpath(row: row_number, column: 4)) do
      expect(page).to have_content(
        DcTimePresenter.convert_and_format(bid.created_at)
      )
    end
  end
end

Then(/^I should not see the bidder name or duns for any bid$/) do
  # sort the bids so that newest is first
  bids = @auction.bids.sort_by(&:created_at).reverse

  # ensure the table has the correct content, in the correct order
  bids.each_with_index do |bid, i|
    row_number = i + 1
    unredacted_bidder_name = bid.bidder.name
    unredacted_bidder_duns = bid.bidder.duns_number

    # check the "name" column
    within(:xpath, cel_xpath(row: row_number, column: 1)) do
      expect(page).not_to have_content(unredacted_bidder_name)
      expect(page).to have_content("[Name withheld until the auction ends]")
    end

    within(:xpath, cel_xpath(row: row_number, column: 2)) do
      expect(page).not_to have_content(unredacted_bidder_duns)
      expect(page).to have_content("[Withheld]")
    end

    # check the "amount" column
    within(:xpath, cel_xpath(row: row_number, column: 3)) do
      expect(page).to have_content(Currency.new(bid.amount).to_s)
    end

    # check the "date" column
    within(:xpath, cel_xpath(row: row_number, column: 4)) do
      expect(page).to have_content(
        DcTimePresenter.convert_and_format(bid.created_at)
      )
    end
  end
end

Then(/^I should see my name and DUNS only on my bids$/) do
  # sort the bids so that newest is first
  bids = @auction.bids.sort_by(&:created_at).reverse

  # ensure the table has the correct content, in the correct order
  bids.each_with_index do |bid, i|
    row_number = i + 1
    if bid.bidder == @user
      bidder_name = bid.bidder.name
      bidder_duns = bid.bidder.duns_number
    else
      bidder_name = '[Name withheld until the auction ends]'
      bidder_duns = '[Withheld]'
    end

    # check the "name" column
    within(:xpath, cel_xpath(row: row_number, column: 1)) do
      expect(page).to have_content(bidder_name)
    end

    within(:xpath, cel_xpath(row: row_number, column: 2)) do
      expect(page).to have_content(bidder_duns)
    end

    # check the "amount" column

    amount = Currency.new(bid.amount).to_s
    within(:xpath, cel_xpath(row: row_number, column: 3)) do
      expect(page).to have_content(amount)
    end

    # check the "date" column
    within(:xpath, cel_xpath(row: row_number, column: 4)) do
      expect(page).to have_content(
        DcTimePresenter.convert_and_format(bid.created_at)
      )
    end
  end
end

Then(/^I should not see bids from other users$/) do
  @auction.bids.each do |bid|
    next if bid.bidder == @user
    expect(page).to_not have_content(Currency.new(bid.amount).to_s)
  end
end

Then(/^I should see my bid history$/) do
  expect(@user.bids.count).to eq(1)
  bid = @user.bids.first
  bid_status = BiddingStatusPresenterFactory.new(@auction).create.label

  expect(page).to have_content("#{@auction.title} #{bid_status} 1 #{Currency.new(bid.amount)} -")
end

Then(/^I should see I have placed no bids$/) do
  expect(page.html).to include(
    I18n.t('labels.vendor.account.bids_placed.no_bids_html',
           index_url: Url.new(link_text: 'current and upcoming auctions', path_name: 'root'))
  )
end
