const {expect} = require('chai');
const {accounts, contract} = require('@openzeppelin/test-environment');

//const [ admin, deployer, user ] = accounts;


const totalSupply = 1000;
// Start test block
describe('Staking', function () {
    const [owner] = accounts;

    before(async function () {
        this.Staking = await ethers.getContractFactory("Staking");
        this.Token = await ethers.getContractFactory("MintableToken");
    });

    beforeEach(async function () {
        const [owner, user] = await ethers.getSigners();
        this.token = await this.Token.deploy('Test', 'TTT');
        await this.token.deployed();
        this.staking = await this.Staking.deploy(this.token.address);
        await this.staking.deployed();
        await this.token.mint(user.address, totalSupply);
    });

    // Test cases
    it('check token', async function () {
        expect((await this.staking.token()).toString()).to.equal(this.token.address);
    });
    it('check totalSupply', async function () {
        expect((await this.token.totalSupply())).to.equal(totalSupply);
    });

    it('check balance', async function () {
        const [owner, user] = await ethers.getSigners();
        let balance = (await this.token.balanceOf(user.address));
        console.log('balance', balance.toString());
        expect(balance).to.equal(totalSupply);
    });

    it('check transfer', async function () {
        const [owner, user1, user2] = await ethers.getSigners();
        await this.token.connect(user1).transfer(user2.address, 500);

        let balance1 = (await this.token.balanceOf(user1.address));
        console.log('balance1', balance1.toString());
        expect(balance1).to.equal(500);

        let balance = (await this.token.balanceOf(user2.address));
        console.log('balance2', balance.toString());
        expect(balance).to.equal(500);
    });

    it('check totalStaked', async function () {
        const [owner, user1, user2] = await ethers.getSigners();
        await this.staking.connect(user1).stake(100, (new Date()).getTime());
        await this.staking.connect(user2).stake(200, (new Date()).getTime());

        let totalStaked = (await this.staking.totalStaked());
        console.log('totalStaked', totalStaked.toString());
        expect(totalStaked).to.equal(300);
    });

    it('check reward', async function () {
        const [owner, user1, user2] = await ethers.getSigners();
        await this.staking.connect(user1).stake(100, (new Date()).getTime());
        await this.staking.connect(user2).stake(300, (new Date()).getTime());

        await this.staking.reward((new Date()).getTime()+3600);

        let totalStaked = (await this.staking.totalStaked());
        console.log('totalStaked', totalStaked.toString());
        expect(totalStaked).to.equal(500);

        let balance1 = (await this.staking.totalStakedFor(user1.address));
        console.log('balance1', balance1.toString());
        expect(balance1).to.equal(125);

        let balance2 = (await this.staking.totalStakedFor(user2.address));
        console.log('balance2', balance2.toString());
        expect(balance2).to.equal(375);
    });

    it('check ary', async function () {
        const [owner, user1, user2] = await ethers.getSigners();
        const user1amount = 100;
        await this.staking.connect(user1).stake(user1amount, (new Date()).getTime());
        await this.staking.connect(user2).stake(300, (new Date()).getTime());

        await this.staking.reward((new Date()).getTime() + 3600);

        let balance1 = (await this.staking.totalStakedFor(user1.address));
        expect(balance1).to.equal(125);

        const ARY_expected = Math.floor(((balance1 - user1amount ) / user1amount) * 100);
        let ARY = (await this.staking.calculateAPY(user1.address));
        console.log('ARY_expected', ARY_expected);
        console.log('ARY', ARY.toString());

    });
});