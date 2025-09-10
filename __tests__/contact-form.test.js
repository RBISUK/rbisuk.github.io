beforeEach(() => {
  jest.resetModules();
  document.body.innerHTML = `
    <form id="contact-form-smart">
      <input name="ttc" />
    </form>
    <div id="form-status"></div>
  `;
});

test('initialises ttc field', async () => {
  await import('../contact-form.js');
  const val = document.querySelector('input[name="ttc"]').value;
  expect(val).not.toBe('');
});
