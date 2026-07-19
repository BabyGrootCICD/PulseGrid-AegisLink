import { render, screen } from '@testing-library/react';
import Home from '../app/page';

describe('Home', () => {
  it('renders a heading', () => {
    render(<Home />);
    
    const heading = screen.getByText(/PulseGrid-AegisLink/i);
    expect(heading).toBeInTheDocument();
  });

  it('renders the platform description', () => {
    render(<Home />);
    
    const description = screen.getByText(/AuraSync Platform/i);
    expect(description).toBeInTheDocument();
  });
});
