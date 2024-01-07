// SPDX-License-Identifier: None

pragma solidity ^0.8.0;

import "./TokenBar.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LoanWolfPool is TokenBar, Ownable{

    //interest rate is consistent for each pool
    uint public interestRate = 1000;       //10% interest default for now
    uint public constant ONE_HUNDRED_PERCENT = 10000;

    //Loan object. Stores lots of info about each loan
    struct loan {
        bool issued;
        address ERC20Address;
        address borrower;
        uint256 paymentPeriod;
        uint256 paymentDueDate;
        uint256 minPayment;
        uint256 principal;
        uint256 totalPaymentsValue;
        uint256 paymentComplete;
    }

    //Two mappings. One to get the loans for a user. And the other to get the the loans based off id
    mapping(uint256 => loan) public loanLookup;
    mapping(address => uint256[]) public loanIDs;

    constructor(address _dai) TokenBar(_dai){}

    /// @notice requires contract is not paid off
    modifier incomplete(uint256 _id){
        require(loanLookup[_id].paymentComplete <
        loanLookup[_id].totalPaymentsValue,
        "This contract is already paid off");
        _;
    }

    function setInterestRate(uint _new) external onlyOwner{
        require(_new <= ONE_HUNDRED_PERCENT, "Cannot have interest over 100%");
        interestRate = _new;
    }

    /**
    * @dev function for a lender to deposit funds and get rToken back
    * @param _amount is the amount to lend
    * @notice the contract must be approved to spend _amount amount of ERC20 first
     */
    function lend(uint _amount) external{
        _enter(_amount, msg.sender);
    }

    /**
    * @dev borrow function to accept a configured loan as a borrower
    * @param _id is the configured loan ID to borrow
     */
    function borrow(uint _id) external{
        require(loanLookup[_id].borrower == msg.sender, "Caller must be a configured borrower");
        loanLookup[_id].issued = true;
        token.transfer(msg.sender, loanLookup[_id].principal);
    }

    /**
    * @notice gets the number of loans a person has
    * @param _who is who to look up
    * @return length
     */
    function getNumberOfLoans(address _who) external virtual view returns(uint256){
        return loanIDs[_who].length;
    }

     /**
    * @notice contract must be configured before bonds are issued. Pushes new loan to array for user
    * @dev borrower is msg.sender for testing. In production might want to make this a param
    * @param _borrower is the borrower loan is being configured for. Keep in mind. ONLY this borrower can mint bonds to start the loan
    * @param _minPayment is the minimum payment that must be made before the payment period ends
    * @param _paymentPeriod payment must be made by this time or delinquent function will return true
    * @param _principal the origional loan value before interest
    * @return the id it just created
     */
    function configureNew(
    address _borrower,
    uint256 _minPayment,
    uint256 _paymentPeriod,
    uint256 _principal
    )
    external
    virtual
    onlyOwner()
    returns(uint256)
    {
        require(_principal <= token.balanceOf(address(this)), "Principal cannot be greater than the token balance");
        //Create new ID for the loan
        uint256 id = getId(_borrower, loanIDs[_borrower].length);
        //Push to loan IDs
        loanIDs[_borrower].push(id);

        //Add loan info to lookup
        loanLookup[id] = loan(
        {
            issued: false,
            ERC20Address: address(token),
            borrower: _borrower,
            paymentPeriod: _paymentPeriod,
            paymentDueDate: block.timestamp + _paymentPeriod,
            minPayment: _minPayment,
            principal: _principal,
            totalPaymentsValue: _principal,               //For now. Will update with interest updates
            paymentComplete: 0
            }
        );

        return id;
    }

    /**
    * @notice function handles the payment of the loan. Does not have to be borrower
    * as payment comes in. The contract holds it until collection by bond owners. MUST APPROVE FIRST in ERC20 contract first
    * @param _id to pay off
    * @param _erc20Ammount is ammount in loan's ERC20 to pay
     */
    function payment(uint256 _id, uint256 _erc20Ammount)
    external
    virtual
    incomplete(_id)
    {
        loan memory ln = loanLookup[_id];
        require(_erc20Ammount >= ln.minPayment ||                                   //Payment must be more than min payment
                ln.totalPaymentsValue - ln.paymentComplete < ln.minPayment,     //Exception for the last payment (remainder)
                "You must make the minimum payment");

        IERC20(ln.ERC20Address).transferFrom(msg.sender, address(this), _erc20Ammount);
        loanLookup[_id].paymentDueDate = block.timestamp + ln.paymentPeriod;             //Reset paymentTimer;
        loanLookup[_id].paymentComplete += _erc20Ammount;                                //Increase paymentComplete
        //Then update interest based of remainder due if there is a remainder due
        if(!isComplete(_id)){
            loanLookup[_id].totalPaymentsValue +=
            ((loanLookup[_id].totalPaymentsValue - loanLookup[_id].paymentComplete) *
            interestRate) /
            ONE_HUNDRED_PERCENT;
        }
    }

    /**
    * @notice helper function
    * @param _id of loan to check
    * @return return if the contract is payed off or not as bool
     */
    function isComplete(uint256 _id) public virtual view returns(bool){
        return loanLookup[_id].paymentComplete >=
        loanLookup[_id].totalPaymentsValue ||
        !loanLookup[_id].issued;
    }

    /**
    * @notice Returns the ID for a loan given the borrower and index in the array
    * @param _borrower is borrower
    * @param _index is the index in the borrowers loan array
    * @return the loan ID
     */
    //
    function getId(address _borrower, uint256 _index) public virtual view returns(uint256){
        uint256 id = uint256(
            keccak256(abi.encodePacked(
            address(this),
            _borrower,
            _index
        )));
        return id;
    }

}
