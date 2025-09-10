import { render, screen } from '@testing-library/react';
import LegalHub from '../src/LegalHub';

test('renders Privacy Policy section', () => {
  render(<LegalHub />);
  expect(screen.getByText(/Privacy Policy/i)).toBeInTheDocument();
});
