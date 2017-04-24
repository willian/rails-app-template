import visit from '../helpers/visit'

describe('When visiting the homepage', () => {
  it('shows header', async () => {
    const page = visit('/')

    const text = await page.evaluate(() => document.body.textContent).end()
    expect(text).toContain('Yay! You’re on Rails!')
  })
})
